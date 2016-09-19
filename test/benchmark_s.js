// Generated by LiveScript 1.5.0
/**
 * User: Roy
 * Date: 2016/9/19
 * Time: 10:25
 */
var natsLib, natsRpc, natsServers, _t_str, _t_json, clientA;
natsLib = require("../index.js");
natsRpc = new natsLib;
natsServers = ['nats://127.0.0.1:4222', 'nats://127.0.0.1:5222'];
_t_str = "ok";
_t_json = {
  a: "def",
  b: 456,
  c: true
};
clientA = natsRpc.Create(natsServers, "clientA", function(){
  console.log("[clientA]-->[init] >>> connected to nats");
  clientA.RegisterRpcHandlerPartial("testString", function(topic, msg, cb){
    return cb(null, _t_str);
  });
  clientA.RegisterRpcHandlerPartial("testJson", function(topic, msg, cb){
    return cb(null, _t_json);
  });
});