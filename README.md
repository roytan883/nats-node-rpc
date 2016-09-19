# nats-node-rpc
## fast nodejs rpc library based on nats

## Features
Normally you should use **_Partial Rpc_**

### *Topic   
A **Topic** is RPC interface name for both client and server.
### Partial Rpc  
Servers A, B, C ... N, can register to the same **Topic**. But only one server will receive client request, then handle it reply to client.
It is always 1 to 1.
### *Full RPC  
Servers A, B, C ... N, can register to the same **Topic**. 
When client call **Topic**, all server will receive the request. But only first response(the fastest one) will be used for client.
> all server still handle the request, just first response(the fastest one) will be handle by client

### *Push and Partial Push
Like **Full RPC** and **Partial Rpc**, but on return data.
### *QueryCallback and Query  
Unlike RPC only first response is valid. All response will be available to QueryCallback.
> Example: you can use 4 servers register **Full RPC** to  **Topic: ServerStatus**. 
> 1 monitor server register **QueryCallback** to **Topic: ServerStatus**, call **Query** on timer, then the monitor server will receive 4 status reports on each timer.
  
### *Partial Named Rpc  
Advanced Partial Rpc, named group servers only one server will get request. eg: 4 named group with total 20 servers, only 4 servers will receive request.


## Install
```
npm install nats-node-rpc
```

## Tests
```
cd test
wget https://github.com/nats-io/gnatsd/releases/download/v0.9.4/gnatsd-v0.9.4-linux-amd64.zip
unzip gnatsd-v0.9.4-linux-amd64.zip
nohup ./gnatsd-v0.9.4-linux-amd64/gnatsd > /dev/null 2>&1 &
node simple
node partialRpc
node xxx
```

## sample
```
var natsLib, natsRpc, natsServers, clientA, clientB, clientC, clientTest;
natsLib = require("nats-node-rpc");
natsRpc = new natsLib;
natsServers = ['nats://127.0.0.1:4222', 'nats://127.0.0.1:5222'];
clientA = natsRpc.Create(natsServers, "clientA", function(){
  console.log("[clientA]-->[init] >>> connected to nats");
  clientA.RegisterRpcHandlerPartial("testFn", function(topic, msg, cb){
    console.log("[clientA]-->[testFn] >>> msg = ", msg);
    return cb(null, "hello from clientA");
  });
});
clientB = natsRpc.Create(natsServers, "clientB", function(){
  console.log("[clientB]-->[init] >>> connected to nats");
  clientB.RegisterRpcHandlerPartial("testFn", function(topic, msg, cb){
    console.log("[clientB]-->[testFn] >>> msg = ", msg);
    return cb(null, "hello from clientB");
  });
});
clientC = natsRpc.Create(natsServers, "clientC", function(){
  console.log("[clientC]-->[init] >>> connected to nats");
  clientC.RegisterRpcHandlerPartial("testFn", function(topic, msg, cb){
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
```
