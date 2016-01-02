# 剥离出来的 HttpClient ，目前仅适合 qqapi 使用
# 返回值：已经解析的json

_ = require('underscore')
https = require "https"
http  = require 'http'
querystring  = require 'querystring'
URL  = require('url')
jsons = JSON.stringify


# 设置全局cookie
all_cookies = []

get_cookies = ->
  all_cookies

get_cookies_string = ->
  cookie_map = {}
  all_cookies.forEach((ck)->
    v = ck.split(' ')[0]
    kv = v.trim().split('=')
    if (kv[1] != ';')
      cookie_map[kv[0]] = kv[1]
  )
  cks = []
  cks.push(k + '=' + value) for k, value of cookie_map
  cks.join(' ')

update_cookies = (cks) ->
  all_cookies = _.union(all_cookies, cks) if cks

global_cookies = (cookie)->
    update_cookies(cookie) if cookie
    return get_cookies()


url_get = (url_or_options, callback, pre_callback) ->
  http_or_https = http

  if (typeof url_or_options is 'string' and url_or_options.indexOf('https:') is 0) or (typeof url_or_options is 'object' and url_or_options.protocol is 'https:')
    http_or_https = https
    if process.env.DEBUG
      console.log url_or_options

  http_or_https.get(url_or_options, (resp) ->
    pre_callback(resp) if pre_callback?
    update_cookies resp.headers['set-cookie']
    res = resp
    body = ''
    resp.on 'data', (chunk) ->
      body += chunk
    resp.on 'end', ->
      if process.env.DEBUG
        console.log(resp.statusCode)
        console.log(resp.headers)
        console.log(body)
      callback 0, res, body
  ).on('error', (e) ->
    console.log(e)
  )


url_post = (options, form, callback) ->
  http_or_https = http
  if (typeof url_or_options is 'string' and url_or_options.indexOf('https:') is 0) or (typeof url_or_options is 'object' and url_or_options.protocol is 'https:')
    http_or_https = https
    if process.env.DEBUG
      console.log url_or_options

  postData = querystring.stringify form

  if typeof options.headers isnt 'object'
    options.headers = {}
  options.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
  options.headers['Content-Length'] = Buffer.byteLength(postData)
  options.headers['Cookie'] = get_cookies_string()
  options.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:27.0) Gecko/20100101 Firefox/27.0'

  if process.env.DEBUG
    console.log options.headers
    console.log postData

  req = http_or_https.request(options, (resp) ->
    res = resp
    body = ''
    resp.on 'data', (chunk) ->
      body += chunk

    resp.on 'end', ->
      if process.env.DEBUG
        console.log resp.statusCode
        console.log resp.headers
        console.log body
      callback 0, res, body
  ).on 'error', (e) ->
    console.log e
  req.write postData
  req.end()

# options url:url
#         method: GET/POST
#         debug:false
# @params 请求参数
# @callback( ret, error)  ret为json序列对象
http_request = (options , params , callback) ->
    aurl = URL.parse( options.url )
    options.host = aurl.host
    options.path = aurl.path
    options.headers ||= {}

    client =  if aurl.protocol == 'https:' then https else http
    body = ''
    if params and options.method == 'POST'
      data = querystring.stringify params
      options.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
      options.headers['Content-Length']= Buffer.byteLength(data)
    if params and options.method == 'GET'
      query = querystring.stringify params
      append = if aurl.query then '&' else '?'
      options.path += append + query

    options.headers['Cookie'] = get_cookies_string()
    options.headers['Referer'] = 'http://d1.web2.qq.com/proxy.html?v=20151105001&callback=1&id=2'
    options.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.86 Safari/537.36';

    req = client.request options, (resp) ->
      if options.debug
        console.log "response: #{resp.statusCode}"
        console.log "cookie: #{resp.headers['set-cookie']}"
      resp.on 'data', (chunk) ->
        body += chunk
      resp.on 'end', ->
        handle_resp_body(body, options, callback)

    req.on "error" , (e)->
        callback(null,e)

    if params and options.method == 'POST'
        req.write(data);
    req.end();

handle_resp_body = (body , options , callback) ->
    err = null
    try
        ret = JSON.parse body
    catch error
        console.log "解析出错", options.url, body
        console.log error
        err = error
        ret = null
    callback(ret,err)


# 2 ways to call it
# url, params, callback or
# url, callback
#
http_get  = (args...) ->
  [url,params,callback] = args
  [params,callback] = [null,params] unless callback
  options =
    method : 'GET'
    url    : url
  http_request options, params, callback

http_post = (options , body, callback) ->
    options.method = 'POST'
    http_request options, body, callback

# 导出方法
module.exports =
    get_cookies: get_cookies
    update_cookies: update_cookies
    get_cookies_string: get_cookies_string
    global_cookies: global_cookies
    request: http_request
    get:     http_get
    post:    http_post
    url_get: url_get
    url_post: url_post
