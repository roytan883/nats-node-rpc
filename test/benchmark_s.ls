/**
 * User: Roy
 * Date: 2016/9/19
 * Time: 10:25
 */

natsLib = require("../index.js")
natsRpc = new natsLib
natsServers = ['nats://127.0.0.1:4222', 'nats://127.0.0.1:5222']

_t_str = "ok"
_t_json = {a:"def", b: 456, c:true}

clientA = natsRpc.Create natsServers, "clientA", !->
  console.log("[clientA]-->[init] >>> connected to nats")
  clientA.RegisterRpcHandlerPartial "testString", (topic, msg, cb) !->
    return cb(null, _t_str)
  clientA.RegisterRpcHandlerPartial "testJson", (topic, msg, cb) !->
    return cb(null, _t_json)

