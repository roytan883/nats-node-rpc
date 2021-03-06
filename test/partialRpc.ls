/**
 * User: Roy
 * Date: 2016/9/19
 * Time: 10:48
 */
natsLib = require("../index.js")
natsRpc = new natsLib
natsServers = ['nats://127.0.0.1:4222', 'nats://127.0.0.1:5222']

clientA = natsRpc.Create natsServers, "clientA", !->
  console.log("[clientA]-->[init] >>> connected to nats")
  clientA.RegisterRpcHandlerPartial "testFn", (topic, msg, cb) !->
#    console.log("[clientA]-->[testFn] >>> topic = ", topic)
    console.log("[clientA]-->[testFn] >>> msg = ", msg)
    return cb(null, "hello from clientA")

clientB = natsRpc.Create natsServers, "clientB", !->
  console.log("[clientB]-->[init] >>> connected to nats")
  clientB.RegisterRpcHandlerPartial "testFn", (topic, msg, cb) !->
#    console.log("[clientB]-->[testFn] >>> topic = ", topic)
    console.log("[clientB]-->[testFn] >>> msg = ", msg)
    return cb(null, "hello from clientB")

clientC = natsRpc.Create natsServers, "clientC", !->
  console.log("[clientC]-->[init] >>> connected to nats")
  clientC.RegisterRpcHandlerPartial "testFn", (topic, msg, cb) !->
#    console.log("[clientC]-->[testFn] >>> topic = ", topic)
    console.log("[clientC]-->[testFn] >>> msg = ", msg)
    return cb(null, "hello from clientC")

clientTest = natsRpc.Create natsServers, "clientTest", !->
  console.log("[clientTest]-->[init] >>> connected to nats")
  setTimeout(!->
    for i til 10
      clientTest.RpcAsync "testFn", "hi from clientTest n = " + i, (err, ret)!->
#        console.log("[clientTest]-->[after testFn] >>> err = ", err)
        console.log("[clientTest]-->[after testFn] >>> ret = ", ret)
  , 1000)