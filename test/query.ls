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
  clientA.RegisterRpcHandlerFull "testFn", (topic, msg, cb) !->
#    console.log("[clientA]-->[testFn] >>> topic = ", topic)
    console.log("[clientA]-->[testFn] >>> msg = ", msg)
    return cb(null, "hello from clientA")

clientB = natsRpc.Create natsServers, "clientB", !->
  console.log("[clientB]-->[init] >>> connected to nats")
  clientB.RegisterRpcHandlerFull "testFn", (topic, msg, cb) !->
#    console.log("[clientB]-->[testFn] >>> topic = ", topic)
    console.log("[clientB]-->[testFn] >>> msg = ", msg)
    return cb(null, "hello from clientB")

clientC = natsRpc.Create natsServers, "clientC", !->
  console.log("[clientC]-->[init] >>> connected to nats")
  clientC.RegisterRpcHandlerFull "testFn", (topic, msg, cb) !->
#    console.log("[clientC]-->[testFn] >>> topic = ", topic)
    console.log("[clientC]-->[testFn] >>> msg = ", msg)
    return cb(null, "hello from clientC")

clientTest = natsRpc.Create natsServers, "clientTest", !->
  console.log("[clientTest]-->[init] >>> connected to nats")
  clientTest.RegisterQueryCallback "testFn", (topic, msg) !->
    console.log("[clientTest]-->[QueryCallback] topic = ", topic)
    console.log("[clientTest]-->[QueryCallback] msg = ", msg)
  setTimeout(!->
    for i til 10
      clientTest.Query "testFn", "hi from clientTest n = " + i
  , 1000)