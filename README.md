Hubot QQ Adapter
------
A hubot adapter for QQ!
由于源项目[qqbot](https://github.com/xhan/qqbot)不支持手机二维码扫描登录，本项目加入了[SmartQQ-Bot](https://github.com/floatinghotpot/qqbot)的二维码扫描登录，同时仍保留源项目的coffeescript实现。由于目前看来源项目已经不再更新和merge pull rquest，本项目暂时以fork的方式存在。

基于[WebQQ协议](https://github.com/xhan/qqbot/blob/master/protocol.md)的QQ机器人和命令行工具。

功能 Features
-----
* 手机QQ二维码扫描登录
* 支持好友，群，讨论组的接入
* 作为hubot adapter使用
* 提供HTTP API支持

你可以用TA来  

* 部署机器人（请了解hubot的概念）
* 聊天机器人（请自己实现AI）
* 通知机器人（监控报警啊什么的，对于天天做电脑前报警还得通过邮件短信提醒多不直接呢）
* 辅助管理群成员，比如自动清理刷屏用户啊（请自己实现）


Acts as Hubot Adapter
------
* Add `hubot-qq` as a dependency in your hubots `package.json`
* Run `npm install` in your hubots directory
* Run hubot with `bin/hubot -a qq`

Configurable Variables
------
把config.demo.yaml拷贝一份重新命名为config.yaml, 在配置文件中设置变量

	account				#QQ号码
	password			#QQ登录密码
	qq_group			#监听的群组名称
	host				#QQ二维码验证服务器名称
	port				#QQ二维码验证服务器端口
	plugins				#插件列表。比如如果要开启API服务，需在在列表中添加apiserver。默认的插件在plugins目录下
	api_port			#API服务器端口
	api_token			#API服务器Token

或者使用下列的环境变量来设置QQ号码等信息，环境变量如果设置会比config.yaml有更高的优先级

	HUBOT_QQ_ID			#QQ ID
	HUBOT_QQ_PASS			#password
	HUBOT_QQ_GROUP			#group name that hubot listens to
	HUBOT_QQ_IMGPORT		#the port to serve verify-codes
	#for more debug variables plz check src/hubot-qq source file

On LINUX or OSX use `export VARIABLE=VALUE` to set environment variables.


独立作为机器人运行
-----
* 执行 `sudo npm install -g coffee-script` 安装 `CoffeeScript`
* 执行 `npm install` 更新依赖
* 配置一份你自己的 `config.yaml`
* 执行 `./main.coffee`


API
----
目前实现的API在[`plugins/apiserver.coffee`](https://github.com/derek-wangpch/qqbot/blob/master/plugins/apiserver.coffee)当中，比如下列API:

1. 信息发送:

  `POST http://localhost:port/send?token={token}&type={type}&to={to}&msg={message}`
参数如下:
  * `type`: 消息类型，为 `buddy`, `group`, `discuss`三种，分别为发送给好友，群组和讨论组
  * `to`: 消息接受者，可以为接受者的名称，比如好友名称或者群名称
  * `msg`: 消息
2. 列出好友列表:

  `GET http://localhost:port/listbuddy?token={token}`

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
* 支持监听多个群组

Credit
---
* QQBot 主要由 [xhan](https://github.com/xhan) 从 2013年12月开始，陆陆续续实现绝大部分功能。
* [Raymond Xie](https://github.com/floatinghotpot) 于 2015年10月 增加了 手机QQ二维码扫描认证登陆。

