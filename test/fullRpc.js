// Generated by LiveScript 1.5.0
/**
 * User: Roy
 * Date: 2016/9/19
 * Time: 10:48
 */
var natsLib, natsRpc, natsServers, clientA, clientB, clientC, clientTest;
natsLib = require("../index.js");
natsRpc = new natsLib;
natsServers = ['nats://127.0.0.1:4222', 'nats://127.0.0.1:5222'];
clientA = natsRpc.Create(natsServers, "clientA", function(){
  console.log("[clientA]-->[init] >>> connected to nats");
  clientA.RegisterRpcHandlerFull("testFn", function(topic, msg, cb){
    console.log("[clientA]-->[testFn] >>> msg = ", msg);
    return cb(null, "hello from clientA");
  });
});
clientB = natsRpc.Create(natsServers, "clientB", function(){
  console.log("[clientB]-->[init] >>> connected to nats");
  clientB.RegisterRpcHandlerFull("testFn", function(topic, msg, cb){
    console.log("[clientB]-->[testFn] >>> msg = ", msg);
    return cb(null, "hello from clientB");
  });
});
clientC = natsRpc.Create(natsServers, "clientC", function(){
  console.log("[clientC]-->[init] >>> connected to nats");
  clientC.RegisterRpcHandlerFull("testFn", function(topic, msg, cb){
    console.log("[clientC]-->[testFn] >>> msg = ", msg);
    return cb(null, "hello from clientC");
  });
});
clientTest = natsRpc.Create(natsServers, "clientTest", function(){
  console.log("[clientTest]-->[init] >>> connected to nats");
  setTimeout(function(){
    var i$, i;
    for (i$ = 0; i$ < 10; ++i$) {
      i = i$;
      clientTest.RpcAsync("testFn", "hi from clientTest n = " + i, fn$);
    }
    function fn$(err, ret){
      console.log("[clientTest]-->[after testFn] >>> ret = ", ret);
    }
  }, 1000);
});