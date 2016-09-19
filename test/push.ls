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
  clientA.RegisterPushHandlerFull "testFn", (topic, msg) !->
#    console.log("[clientA]-->[testFn] >>> topic = ", topic)
    console.log("[clientA]-->[testFn] >>> msg = ", msg)

clientB = natsRpc.Create natsServers, "clientB", !->
  console.log("[clientB]-->[init] >>> connected to nats")
  clientB.RegisterPushHandlerFull "testFn", (topic, msg) !->
#    console.log("[clientB]-->[testFn] >>> topic = ", topic)
    console.log("[clientB]-->[testFn] >>> msg = ", msg)

clientC = natsRpc.Create natsServers, "clientC", !->
  console.log("[clientC]-->[init] >>> connected to nats")
  clientC.RegisterPushHandlerFull "testFn", (topic, msg) !->
#    console.log("[clientC]-->[testFn] >>> topic = ", topic)
    console.log("[clientC]-->[testFn] >>> msg = ", msg)

clientTest = natsRpc.Create natsServers, "clientTest", !->
  console.log("[clientTest]-->[init] >>> connected to nats")
  setTimeout(!->
    for i til 10
      clientTest.Push "testFn", "hi from clientTest n = " + i
  , 1000)

