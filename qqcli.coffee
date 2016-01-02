http = require 'http'
querystring = require 'querystring'
config = require './config'

qqcli =
    api_get: (path, callback) ->
        url = "http://localhost:" + config.api_port + path
        http.get(url, (resp)->
            body = ''
            res = resp
            resp.on 'data', (chunk) ->
                body += chunk
            resp.on 'end', ->
                callback null, res, body
        ).on "error", (e) ->
            callback e, null, null


    api_post: (path, form, callback) ->
        postData = querystring.stringify form
        options =
            hostname: 'localhost'
            port    : config.api_port
            path    : path
            method  : 'POST'
            headers:
                'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8'
                'Content-Length': postData.length
        req = http.request(options, (resp) ->
            res = resp
            body = ''
            resp.on 'data', (chunk) ->
                body += chunk
            resp.on 'end', ->
                callback null, res, body
        ).on 'error', (e) ->
            callback e, null, null
        req.write postData
        req.end()

    listBuddy: ->
        @api_get "/listbuddy", (err, resp, body) ->
            return console.log('qqbot not started.\n') if not body
            i = 0
            JSON.parse(body).info.forEach (inf)->
                console.log("  " + (++i) + ', ' + inf.nick + ' ( ' + inf.account + ' )')
            console.log()

    listGroup: ->
        @api_get "/listgroup", (err, resp, body) ->
            return console.log('qqbot not started.\n') if not body
            i = 0
            JSON.parse(body).gnamelist.forEach (inf)->
                console.log("  " + (++i) + ', ' + inf.name + ' ( ' + inf.account + ' )')
            console.log()

    listDiscuss: ->
        @api_get "/listdiscuss", (err, resp, body) ->
            return console.log('qqbot not started.\n') if not body
            console.log err, body
            ret = JSON.parse(body)
            info = ret.dnamelist

    list: (args) ->
        return @cli_usage() if args.length != 1
        switch args[0]
            when 'buddy' then @listBuddy()
            when 'group' then @listGroup()
            when 'discuss' then @listDiscuss()
            else console.log "Unknown args: #{args[0]}"

    send: (args) ->
        return @cli_usage() if args.length != 3
        @api_post("/send",
            type: args[0]
            to: args[1]
            msg: args[2]
        , (err, resp, body) ->
            return console.log('qqbot not started.\n') if not body
            console.log(body + '\n')
        )

    relogin: ->
        @api_get '/relogin', (err, resp, body) ->
            return console.log('qqbot not started.\n') if not body
            ret = JSON.parse body
            console.log ret.msg + "\n"

    quit: ->
        @api_get "/quit", (err, resp, body) ->
            return console.log('qqbot not started.\n') if not body
            ret = JSON.parse body
            console.log ret.msg + "\n"
    cli_usage: ->
        info = require('./package.json')
        ver_info = info.name + ', v' + info.version + '\n' +
            'project url:' + info.repository.url + '\n'
        syntax = """
            Syntax:
            qq list [buddy | group | discuss]
            qq send [buddy | group | discuss] <msg>
            qq relogin
            qq quit
        """
        console.log ver_info
        console.log syntax

    main: (argv) ->
        @cli = argv[1]
        args = argv.slice 2
        return @cli_usage if args.length == 0
        switch args[0]
            when 'list' then @list args.slice(1)
            when 'send' then @send args.slice(1)
            when 'relogin' then @relogin()
            when 'quit' then @quit()
            else @cli_usage()

qqcli.main process.argv