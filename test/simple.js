// Generated by LiveScript 1.5.0
/**
 * User: Roy
 * Date: 2016/9/19
 * Time: 10:25
 */
var natsLib, natsRpc, natsServers, clientA, clientB;
natsLib = require("../index.js");
natsRpc = new natsLib;
natsServers = ['nats://127.0.0.1:4222', 'nats://127.0.0.1:5222'];
clientA = natsRpc.Create(natsServers, "clientA", function(){
  console.log("[clientA]-->[init] >>> connected to nats");
  clientA.RegisterRpcHandlerFull("callClientA", function(topic, msg, cb){
    console.log("[clientA]-->[callClientA] >>> topic = ", topic);
    console.log("[clientA]-->[callClientA] >>> msg = ", msg);
    return cb(null, "hello from callClientA");
  });
});
clientB = natsRpc.Create(natsServers, "clientB", function(){
  console.log("[clientB]-->[init] >>> connected to nats");
  setTimeout(function(){
    clientB.RpcAsync("callClientA", "hi from clientB", function(err, ret){
      console.log("[clientB]-->[after callClientA] >>> err = ", err);
      console.log("[clientB]-->[after callClientA] >>> ret = ", ret);
    });
  }, 1000);
});