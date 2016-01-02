Hubot QQ Adapter
------
A hubot adapter for QQ!
由于源项目[qqbot](https://github.com/xhan/qqbot)不支持手机二维码扫描登录，本项目加入了[SmartQQ-Bot](https://github.com/floatinghotpot/qqbot)的二维码扫描登录，同时仍保留源项目的coffeescript实现。由于目前看来源项目已经不再更新和merge pull rquest，本项目暂时以fork的方式存在。

基于[WebQQ协议](https://github.com/xhan/qqbot/blob/master/protocol.md)的QQ机器人。命令行工具，由不可思议的CoffeeScript提供支持。 

功能 Features
-----
* 手机QQ二维码扫描登录
* 支持好友，群，讨论组的接入
* 作为hubot adapter使用
* 提供HTTP API支持（比如群通知什么的都能做哦）

你可以用TA来  

* 辅助管理群成员，比如自动清理刷屏用户啊（请自己实现）
* 聊天机器人（请自己实现AI）
* 部署机器人（请了解hubot的概念）
* 通知机器人（监控报警啊什么的，对于天天做电脑前报警还得通过邮件短信提醒多不直接呢）


Acts as Hubot Adapter
------
* Add `hubot-qq` as a dependency in your hubots `package.json`
* Run `npm install` in your hubots directory
* Run hubot with `bin/hubot -a qq`

Configurable Variables

	HUBOT_QQ_ID			#QQ ID
	HUBOT_QQ_PASS		#password
	HUBOT_QQ_GROUP		#group name that hubot listens to
	HUBOT_QQ_IMGPORT    #the port to serve verify-codes
	#for more debug variables plz check src/hubot-qq source file

On LINUX or OSX use `export VARIABLE=VALUE` to set environment variables.


独立作为机器人运行
-----
* 执行 `sudo npm install -g coffee-script` 安装 `CoffeeScript`
* 执行 `npm install` 更新依赖
* 配置一份你自己的 `config.yaml`
* 执行 `./main.coffee` 让你的机器人躁起来~


我常用的命令 `./main.coffee nologin &>> tmp/dev.log &` , 也可以使用进程管理工具比如 `pm2` 更省心


API
----
TODO GET http://localhost:port/stdin?token=(token)&value=(value)  

改动
----
https://github.com/derek-wangpch/qqbot/blob/master/CHANGELOG.md

资料
----
* WebQQ协议     https://github.com/derek-wangpch/qqbot/blob/master/protocol.md
* Java版的另一个 http://webqq-core.googlecode.com/

TODO
---
* 代码整理
* 做为一个单独的npm包上线
* 图片发送支持

Credit
---
* QQBot 主要由 [xhan](https://github.com/xhan) 从 2013年12月开始，陆陆续续实现绝大部分功能。
* [Raymond Xie](https://github.com/floatinghotpot) 于 2015年10月 增加了 手机QQ二维码扫描认证登陆。

