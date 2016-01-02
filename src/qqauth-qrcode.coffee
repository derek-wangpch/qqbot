
fs = require 'fs'
os = require 'os'
https = require 'https'
http = require 'http'
crypto = require 'crypto'
queryString = require 'querystring'
Url = require 'url'
Path = require 'path'
Log = require 'log'
encryptPass = require './encrypt'
client = require './httpclient'

log = new Log 'debug'

client_id = 53999199

getUserHome = ->
    if process.platform == 'win32'
        process.env['USERPROFILE']
    else
        process.env['HOME']

md5 = (str) ->
    crypto.createHash('md5').update(str.toString()).digest('hex')


prepare_login = (callback) ->
    client.update_cookies('RK=OfeLBai4FB; ptcz=ad3bf14f9da2738e09e498bfeb93dd9da7540dea2b7a71acfb97ed4d3da4e277; pgv_pvi=911366144; ptisp=ctc; pgv_info=ssid=s5714472750; pgv_pvid=1051433466; qrsig=hJ9GvNx*oIvLjP5I5dQ19KPa3zwxNI62eALLO*g2JLbKPYsZIRsnbJIxNe74NzQQ;'.split(' '))
    url = 'https://ui.ptlogin2.qq.com/cgi-bin/login?daid=164&target=self&style=16&mibao_css=m_webqq&appid=501004106&enable_qlogin=0&no_verifyimg=1&s_url=http%3A%2F%2Fw.qq.com%2Fproxy.html&f_url=loginerroralert&strong_login=1&login_state=10&t=20131024001'
    client.url_get url, (err, resp, body)->
        callback []

check_qq_verify = (callback) ->
    options =
        protocol: 'https:'
        host    : 'ssl.ptlogin2.qq.com'
        path    : '/ptqrlogin?webqq_type=10&remember_uin=1&login2qq=1&aid=501004106&u1=http%3A%2F%2Fw.qq.com%2Fproxy.html%3Flogin2qq%3D1%26webqq_type%3D10&ptredirect=0&ptlang=2052&daid=164&from_ui=1&pttype=1&dumy=&fp=loginerroralert&action=0-0-' + (Math.random() * 900000 + 1000000) + '&mibao_css=m_webqq&t=undefined&g=1&js_type=0&js_ver=10141&login_sig=&pt_randsalt=0'
        headers :
            Cookie : client.get_cookies_string()
            Referer: 'https://ui.ptlogin2.qq.com/cgi-bin/login?daid=164&target=self&style=16&mibao_css=m_webqq&appid=501004106&enable_qlogin=0&no_verifyimg=1&s_url=http%3A%2F%2Fw.qq.com%2Fproxy.html&f_url=loginerroralert&strong_login=1&login_state=10&t=20131024001'

    client.url_get(options, (err, resp, body)->
        ret = body.match(/\'(.*?)\'/g).map (i)->
            last = i.length - 2
            i.substr 1, last
        callback ret
    )

get_qr_code = (qq, host, port, callback) ->
    url = "https://ssl.ptlogin2.qq.com/ptqrshow?appid=501004106&e=0&l=M&s=5&d=72&v=4&t=" + Math.random()
    client.url_get url, (err, resp, body)->
        create_img_server host, port, body, resp.headers
        callback()
    , (resp)->
        resp.setEncoding('binary');


finish_verify_code = ->
    stop_img_server()


create_img_server = (host, port, body, origin_header)->
    return if img_server?
    dir_path = Path.join(getUserHome(), '.tmp')
    fs.mkdirSync(dir_path) if not fs.existsSync(dir_path)

    file_path = Path.join(getUserHome(), '.tmp', 'qrcode.jpg')
    fs.writeFileSync file_path, body, 'binary'
    if process.platform isnt 'darwin'
        img_server = http.createServer((req, res)->
            res.writeHead 200, origin_header
            res.end body, 'binary'
        )
        img_server.listen port
    else
        return

stop_img_server = ->
    img_server.close() if img_server
    img_server = null


get_ptwebqq = (url, callback) ->
    client.url_get url, (err, resp, body) ->
        if not err
            callback body

get_vfwebqq = (ptwebqq, callback) ->
    client.url_get(
        method  : 'GET'
        protocol: 'http:'
        host    : 's.web2.qq.com'
        path    : '/api/getvfwebqq?ptwebqq=' + ptwebqq + '&clientid=' + client_id + '&psessionid=&t=' + Math.random()
        headers :
            Cookie: client.get_cookies_string()
            Origin: 'http://s.web2.qq.com'
            Referer: 'http://s.web2.qq.com/proxy.html?v=20130916001&callback=1&id=1'
    , (err, resp, body)->
        ret = JSON.parse(body)
        callback(ret)
    )

login_token = (ptwebqq, psessionid, callback) ->
    psessionid = null if not psessionid
    form =
        r: JSON.stringify(
            ptwebqq     : ptwebqq
            clientid    : client_id
            psessionid  : psessionid || ''
            status      : "online"
        )

    client.url_post(
        protocol: 'http:'
        host: 'd1.web2.qq.com'
        path: '/channel/login2'
        method: 'POST'
        headers:
            Origin: 'http://d1.web2.qq.com'
            Referer: 'http://d1.web2.qq.com/proxy.html?v=20151105001&callback=1&id=2'
    , form, (err, resp, body) ->
        ret = JSON.parse body
        callback ret
    )

get_buddy = (vfwebqq, psessionid, callback) ->
    client.url_get(
        method  : 'GET'
        protocol: 'http:'
        host    : 'd1.web2.qq.com'
        path    : '/channel/get_online_buddies2?vfwebqq=' + vfwebqq + '&clientid=' + client_id + '&psessionid=' + psessionid + '&t=' + Math.random()
        headers :
            Cookie: client.get_cookies_string()
            Origin: 'http://d1.web2.qq.com'
            Referer: 'http://d1.web2.qq.com/proxy.html?v=20151105001&callback=1&id=2'
    , (err, resp, body) ->
        ret = JSON.parse body
        callback body
    )

auto_login = (ptwebqq, callback) ->
    log.info "登录 step3 获取 vfwebqq"
    get_vfwebqq(ptwebqq, (ret) ->
        if ret.retcode is 0
            vfwebqq = ret.result.vfwebqq

            log.info "登录 step4 获取 uin, psessionid"
            login_token ptwebqq, null, (ret) ->
                if ret.retcode is 0
                    log.info '登录成功'
                    auth_options =
                        clientid: client_id
                        ptwebqq: ptwebqq
                        vfwebqq: vfwebqq
                        uin: ret.result.uin
                        psessionid: ret.result.psessionid
                    log.info "登录 step5 获取 好友列表"
                    get_buddy vfwebqq, ret.result.psessionid, (ret)->
                        callback client.get_cookies(), auth_options

                else
                    log.info "登录失败"
                    log.error ret
        else
            log.info "登录失败"
            log.error ret
    )


wait_scan_qrcode = (callback) ->
    log.info "登录 step1 等待二维码校验结果"
    check_qq_verify (ret)->
        retcode = parseInt ret[0]
        if retcode is 0 and ret[2].match /^http/
            log.info "登录 step2 cookie 获取 ptwebqq"
            get_ptwebqq(ret[2], (ret)->
                ptwebqq = client.get_cookies().filter((item) ->
                    item.match(/ptwebqq/)
                ).pop().replace(/ptwebqq\=(.*?);.*/, '$1')
                auto_login ptwebqq, callback
            )
        else if retcode is 66 or retcode is 67
            setTimeout wait_scan_qrcode, 1000, callback
        else
            log.error "登录 step1 failed", ret
            return


auth_with_qrcode = (opt, callback) ->
    qq = opt.account
    log.info "登录 step0.5 获取二维码"
    get_qr_code qq, opt.host, opt.port, (error) ->
        if process.platform is 'darwin'
            log.notice "请用 手机QQ 扫描该二维码"
            file_path = Path.join(getUserHome(), ".tmp", "qrcode.jpg")
            require('child_process').exec('open ' + file_path)
        else
            log.notice "请用 手机QQ 扫描该地址的二维码图片->", "http://" + opt.host + ":" + opt.port

        wait_scan_qrcode callback


# 全局登录函数，如果有验证码会建立一个 http-server ，同时写入 tmp/*.jpg (osx + open. 操作)
# http-server 的端口和显示地址可配置
# @param options {account,password,port,host}
# @callback( cookies , auth_options ) if login success

login = (options, callback) ->
    opt = options
    qq = opt.account
    pass = opt.password
    prepare_login((result) ->
        log.info '登录 step0 - 登录方式检测'
        check_qq_verify (ret)->
            need_verify = parseInt(ret[0])
            verify_code = ret[1]
            bits = ret[2]
            verifySession = ret[3]
            if need_verify == 65 or need_verify == 66
                auth_with_qrcode opt, callback
            else
                console.log result
    )


module.exports =
    prepare_login: prepare_login
    check_qq_verify: check_qq_verify
    get_qr_code: get_qr_code
    get_ptwebqq: get_ptwebqq
    get_vfwebqq: get_vfwebqq
    login_token: login_token
    get_buddy: get_buddy
    finish_verify_code: finish_verify_code
    auth_with_qrcode: auth_with_qrcode
    auto_login: auto_login
    login: login