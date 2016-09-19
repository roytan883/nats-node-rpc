/**
 * User: Roy
 * Date: 2016/9/19
 * Time: 10:10
 */

nats = require 'nats'

#servers = ['nats://192.168.1.69:4222', 'nats://192.168.1.69:5222']

exp = (natsServers, selfName, connectCb) !->
  _self = this
  this.defaultRpcTimeout = 1000 * 30
  this.natsServers = natsServers
  this.subsQuery = {}
  this.subsFull = {}
  this.subsPartial = {}
  this.subsPartialNamed = {}
  this.subsPushFull = {}
  this.subsPushPartial = {}
  this.subsPushPartialNamed = {}
  this.client = nats.connect({
#    verbose:true
#    pedantic:true
#    noRandomize:false
    reconnect:true
    reconnectTimeWait:1000 * 2
    maxReconnectAttempts:30 * 60 * 24 * 30 * 12 * 10
    servers:natsServers
  })
  this.requestsSeq = 0
  this.requestsCbs = {}
  this.replySubString = "Reply." + selfName + "."
  this.replyQuerySubString = "ReplyQ." + selfName + "."
  this.replySub = _self.client.subscribe(_self.replySubString + ">", (msg, reply, subject) !->
#    if typeof msg == 'string' && msg[0] = '{'
#      try msg = JSON.parse(msg)
    _subject = subject
    _topicTokens = _subject.split(".")
    if _topicTokens.length < 1 then return
    seq = _topicTokens[_topicTokens.length - 1]
    msg = _self.parseJson(msg)
#    seq = subject.substring(_self.replySubString.length)
    if _self.requestsCbs[seq]
      cb = _self.requestsCbs[seq].cb
      clearTimeout(_self.requestsCbs[seq].timer)
      delete _self.requestsCbs[seq]
      cb(null, msg)
  )
  _self.inited = false
  if connectCb
    _self.client.once 'connect' !->
      if !_self.inited
        _self.inited = true
        connectCb()
    _self.client.once 'reconnect' !->
      if !_self.inited
        _self.inited = true
        connectCb()

exp.prototype.SetDefaultRpcTimeout = (timeout) ->
  _self = this
  if timeout < 1000 * 1
    _self.defaultRpcTimeout = 1000
  else
    _self.defaultRpcTimeout = timeout

exp.prototype.parseJson = (msg) ->
  retMsg = msg
  if typeof msg == 'string' && msg[0] = '{'
    try
      retMsg = JSON.parse(msg)
      if retMsg && retMsg.type == 'Buffer'
        retMsg = new Buffer(retMsg.data)
  return retMsg

exp.prototype.publishRaw = (to, msg) !->
  _self = this
#  #console.log("publishRaw = ", &)
  if typeof msg == 'object'
    str = JSON.stringify(msg)
#    #console.log("publishRaw object str = ", str)
    return _self.client.publish(to, str)
  else
    return _self.client.publish(to, msg)

exp.prototype.publishRawWithReply = (to, msg, reply) !->
  _self = this
#  #console.log("publishRawWithReply = ", &)
  if typeof msg == 'object'
    str = JSON.stringify(msg)
#    #console.log("publishRawWithReply 111 to = ", to)
#    #console.log("publishRawWithReply 111 str = ", str)
#    #console.log("publishRawWithReply 111 reply = ", reply)
    return _self.client.publish(to, str, reply)
  else
#    #console.log("publishRawWithReply 222 to = ", to)
#    #console.log("publishRawWithReply 22 msg = ", msg)
#    #console.log("publishRawWithReply 222 reply = ", reply)
#    #console.log("publishRawWithReply object str = ", str)
    return _self.client.publish(to, msg, reply)

exp.prototype.RegisterQueryCallback = (topic, handler) !->
  #console.log("[rpc] RegisterQueryCallback topic = ", topic)
  _self = this
  if topic.length <= 0 then return
  _topic = _self.replyQuerySubString + topic
  if _self.subsQuery[_topic]
    _self.client.unsubscribe(_self.subsQuery[_topic])
    delete _self.subsQuery[_topic]
#  console.log("subscribe Query _topic = ", _topic)
  _self.subsQuery[_topic] = _self.client.subscribe(_topic, (msg, reply, subject) !->
#    console.log("recv Query = ", &)
    msg = _self.parseJson(msg)
    handler(subject, msg)
  )

exp.prototype.UnRegisterQueryCallbackAll = !->
  _self = this
  for k,v of _self.subsQuery
    _self.client.unsubscribe(v)
  _self.subsQuery = {}



#exp.prototype.RegisterQueryHandler = (topic, handler) !->
#  _self = this
#  _self.RegisterRpcHandlerFull(topic, handler)

exp.prototype.RegisterHookRpcHandlerFull = (topic, handler) !->
  #console.log("[rpc] RegisterHookRpcHandlerFull topic = ", topic)
  _self = this
  if _self.subsFull[topic]
    _self.client.unsubscribe(_self.subsFull[topic])
    delete _self.subsFull[topic]
  _self.subsFull[topic] = _self.client.subscribe(topic, (msg, reply, subject) !->
    msg = _self.parseJson(msg)
    handler(subject, msg)
  )

exp.prototype.RegisterHookReplyHandlerFull = (topic, handler) !->
  #console.log("[rpc] RegisterHookReplyHandlerFull topic = ", topic)
  _self = this
  topic = "Reply.*." + topic + ".>"
  if _self.subsFull[topic]
    _self.client.unsubscribe(_self.subsFull[topic])
    delete _self.subsFull[topic]
  _self.subsFull[topic] = _self.client.subscribe(topic, (msg, reply, subject) !->
    msg = _self.parseJson(msg)
    handler(subject, msg)
  )

exp.prototype.RegisterRpcHandlerFull = (topic, handler) !->
  #console.log("[rpc] RegisterRpcHandlerFull topic = ", topic)
  _self = this
  if _self.subsFull[topic]
    _self.client.unsubscribe(_self.subsFull[topic])
    delete _self.subsFull[topic]
  _self.subsFull[topic] = _self.client.subscribe(topic, (msg, reply, subject) !->
#    console.log("RegisterRpcHandlerFull = ", &)
#    #console.log("RegisterRpcHandlerFull msg.isBuffer = ", Buffer.isBuffer(msg))
    msg = _self.parseJson(msg)
#    console.log("RegisterRpcHandlerFull msg = ", msg)
#    #console.log("RegisterRpcHandlerFull msg.isBuffer2 = ", Buffer.isBuffer(msg))
    try
      handler(subject, msg, (err, result) !->
        if typeof reply ~= 'string' && reply.length > 0
          if err
            _self.publishRaw(reply, err)
          else
            _self.publishRaw(reply, result)
        else
          console.error("[rpc] RegisterRpcHandlerFull reply error = ", reply)
      )
    catch
      console.error("[rpc] RegisterRpcHandlerFull Exception = ", e)
      _self.publishRaw(reply, {code:500, err_string:"Server Exception"})
  )

exp.prototype.RegisterRpcHandlerPartial = (topic , handler) !->
  #console.log("[rpc] RegisterRpcHandlerPartial topic = ", topic)
  _self = this
  if _self.subsPartial[topic]
    _self.client.unsubscribe(_self.subsPartial[topic])
    delete _self.subsPartial[topic]
  _self.subsPartial[topic] = _self.client.subscribe(topic, {queue:'default'}, (msg, reply, subject) !->
    msg = _self.parseJson(msg)
    try
      handler(subject, msg, (err, result) !->
        if typeof reply ~= 'string' && reply.length > 0
          if err
            _self.publishRaw(reply, err)
          else
            _self.publishRaw(reply, result)
        else
          console.error("[rpc] RegisterRpcHandlerPartial reply error = ", reply)
      )
    catch
      console.error("[rpc] RegisterRpcHandlerPartial Exception = ", e)
      _self.publishRaw(reply, {code:500, err_string:"Server Exception"})
  )

exp.prototype.RegisterRpcHandlerPartialNamed = (topic , partialNamed, handler) !->
  #console.log("[rpc] RegisterRpcHandlerPartialNamed topic = ", topic)
  _self = this
  if _self.subsPartialNamed[topic]
    _self.client.unsubscribe(_self.subsPartialNamed[topic])
    delete _self.subsPartialNamed[topic]
  _self.subsPartialNamed[topic] = _self.client.subscribe(topic, {queue:partialNamed}, (msg, reply, subject) !->
    msg = _self.parseJson(msg)
    try
      handler(subject, msg, (err, result) !->
        if typeof reply ~= 'string' && reply.length > 0
          if err
            _self.publishRaw(reply, err)
          else
            _self.publishRaw(reply, result)
        else
          console.error("[rpc] RegisterRpcHandlerPartialNamed reply error = ", reply)
      )
    catch
      console.error("[rpc] RegisterRpcHandlerPartialNamed Exception = ", e)
      _self.publishRaw(reply, {code:500, err_string:"Server Exception"})
  )

exp.prototype.UnRegisterRpcHandlerFull = (topic) !->
  _self = this
  if _self.subsFull[topic]
    _self.client.unsubscribe(_self.subsFull[topic])
    delete _self.subsFull[topic]

exp.prototype.UnRegisterRpcHandlerPartial = (topic) !->
  _self = this
  if _self.subsPartial[topic]
    _self.client.unsubscribe(_self.subsPartial[topic])
    delete _self.subsPartial[topic]

exp.prototype.UnRegisterRpcHandlerPartialNamed = (topic) !->
  _self = this
  if _self.subsPartialNamed[topic]
    _self.client.unsubscribe(_self.subsPartialNamed[topic])
    delete _self.subsPartialNamed[topic]

exp.prototype.UnRegisterRpcHandlerAll = !->
  _self = this
  for k,v of _self.subsFull
    _self.client.unsubscribe(v)
  for k,v of _self.subsPartial
    _self.client.unsubscribe(v)
  for k,v of _self.subsPartialNamed
    _self.client.unsubscribe(v)
  _self.subsFull = {}
  _self.subsPartial = {}
  _self.subsPartialNamed = {}

exp.prototype.RegisterPushHandlerFull  = (topic, handler) !->
  #console.log("[rpc] RegisterPushHandlerFull topic = ", topic)
  _self = this
  if _self.subsPushFull[topic]
    _self.client.unsubscribe(_self.subsPushFull[topic])
    delete _self.subsPushFull[topic]
  _self.subsPushFull[topic] = _self.client.subscribe(topic, (msg, reply, subject) !->
    msg = _self.parseJson(msg)
    handler(subject, msg)
  )

exp.prototype.RegisterPushHandlerPartial = (topic , handler) !->
  #console.log("[rpc] RegisterPushHandlerPartial topic = ", topic)
  _self = this
  if _self.subsPushPartial[topic]
    _self.client.unsubscribe(_self.subsPushPartial[topic])
    delete _self.subsPushPartial[topic]
  _self.subsPushPartial[topic] = _self.client.subscribe(topic, {queue:'default'}, (msg, reply, subject) !->
    msg = _self.parseJson(msg)
    handler(subject, msg)
  )

exp.prototype.RegisterPushHandlerPartialNamed = (topic , partialNamed, handler) !->
  #console.log("[rpc] RegisterPushHandlerPartialNamed topic = ", topic)
  _self = this
  if _self.subsPushPartialNamed[topic]
    _self.client.unsubscribe(_self.subsPushPartialNamed[topic])
    delete _self.subsPushPartialNamed[topic]
  _self.subsPushPartialNamed[topic] = _self.client.subscribe(topic, {queue:partialNamed}, (msg, reply, subject) !->
    msg = _self.parseJson(msg)
    handler(subject, msg)
  )

exp.prototype.UnRegisterPushHandlerFull = (topic) !->
  _self = this
  if _self.subsPushFull[topic]
    _self.client.unsubscribe(_self.subsPushFull[topic])
    delete _self.subsPushFull[topic]

exp.prototype.UnRegisterPushHandlerPartial = (topic) !->
  _self = this
  if _self.subsPushPartial[topic]
    _self.client.unsubscribe(_self.subsPushPartial[topic])
    delete _self.subsPushPartial[topic]

exp.prototype.UnRegisterPushHandlerPartialNamed = (topic) !->
  _self = this
  if _self.subsPushPartialNamed[topic]
    _self.client.unsubscribe(_self.subsPushPartialNamed[topic])
    delete _self.subsPushPartialNamed[topic]

exp.prototype.UnRegisterPushHandlerAll = !->
  _self = this
  for k,v of _self.subsPushFull
    _self.client.unsubscribe(v)
  for k,v of _self.subsPushPartial
    _self.client.unsubscribe(v)
  for k,v of _self.subsPushPartialNamed
    _self.client.unsubscribe(v)
  _self.subsPushFull = {}
  _self.subsPushPartial = {}
  _self.subsPushPartialNamed = {}

exp.prototype.Query = (topic, msg) !->
  _self = this
  replyString = _self.replyQuerySubString + topic
  console.log("Query topic = ", topic)
  console.log("Query replyString = ", replyString)
  _self.publishRawWithReply(topic, msg, replyString)

exp.prototype.Push = (topic, msg) ->
  _self = this
  _self.publishRaw(topic, msg)

exp.prototype.RpcAsync = (topic, msg, callback) !->
  _self = this
  _self.RpcAsyncTimeout(topic, msg, _self.defaultRpcTimeout, callback)

exp.prototype.RpcAsyncTimeout = (topic, msg, timeout, callback) !->
  _self = this
  _self.requestsSeq++
  seq = "" + _self.requestsSeq
#  #console.log("Rpc seq = ", seq)
  replyString = _self.replySubString + topic + "." + seq
  timer = setTimeout(!->
#    callback(null, {code:500, err_string:"RPC Timeout:" + timeout + "ms"})
    callback(new Error("RPC Timeout:" + timeout + "ms"))
#    callback({code:500, err_string:"RPC Timeout:" + timeout + "ms"})
    if _self.requestsCbs[seq]
      delete _self.requestsCbs[seq]
  , timeout)
  _self.requestsCbs[seq] = {
    seq:seq
    timer:timer
    cb:callback
  }
  #console.log("RpcAsyncTimeout topic = ", topic)
  #console.log("RpcAsyncTimeout replyString = ", replyString)
  _self.publishRawWithReply(topic, msg, replyString)

exp.prototype.Close = !->
  _self = this
  _self.UnRegisterRpcHandlerAll()
  _self.UnRegisterPushHandlerAll()
  _self.UnRegisterQueryCallbackAll()
  _self.client.close()

outExp = !->

outExp.prototype.Create = (natsServers, selfName, connectCb) !->
  return new exp(natsServers, selfName, connectCb)

module.exports = outExp
