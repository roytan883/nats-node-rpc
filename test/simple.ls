/**
 * User: Roy
 * Date: 2016/9/19
 * Time: 10:25
 */

natsLib = require("../index.js")
natsRpc = new natsLib
natsServers = ['nats://127.0.0.1:4222', 'nats://127.0.0.1:5222']

clientA = natsRpc.Create natsServers, "clientA", !->
  console.log("[clientA]-->[init] >>> connected to nats")
  clientA.RegisterRpcHandlerFull "callClientA", (topic, msg, cb) !->
    console.log("[clientA]-->[callClientA] >>> topic = ", topic)
    console.log("[clientA]-->[callClientA] >>> msg = ", msg)
    return cb(null, "hello from callClientA")

clientB = natsRpc.Create natsServers, "clientB", !->
  console.log("[clientB]-->[init] >>> connected to nats")
  setTimeout(!->
    clientB.RpcAsync "callClientA", "hi from clientB", (err, ret)!->
      console.log("[clientB]-->[after callClientA] >>> err = ", err)
      console.log("[clientB]-->[after callClientA] >>> ret = ", ret)
  , 1000)
  setTimeout(!->
    clientB.RpcAsync "invalid", "hi from clientB", (err, ret)!->
      console.log("[clientB]-->[after invalid] >>> err = ", err)
      console.log("[clientB]-->[after invalid] >>> ret = ", ret)
  , 1000)
  setTimeout(!->
    clientB.RpcAsyncTimeout "invalid", "hi from clientB", 2000, (err, ret)!->
      console.log("[clientB]-->[after invalid 2000ms] >>> err = ", err)
      console.log("[clientB]-->[after invalid 2000ms] >>> ret = ", ret)
  , 1000)

