/**
 * User: Roy
 * Date: 2016/9/19
 * Time: 10:25
 */

natsLib = require("../index.js")
natsRpc = new natsLib
natsServers = ['nats://127.0.0.1:4222', 'nats://127.0.0.1:5222']

#kkk = "abc"
#console.log(typeof kkk == 'string')
#return

clientB = natsRpc.Create natsServers, "clientB", !->
  console.log("[clientB]-->[init] >>> connected to nats")

#clientB.RpcAsync "testJson", {aa:"abcdef", bb: 123, cc:true}, (err, ret)!->
#  console.log(&)
#  return

_t_str = "hi"
_t_json = {aa:"abcdef", bb: 123, cc:true}
_test_count = 10000 * 10
_sequence_count = 100

setTimeout(!->
  testString_count_max = _test_count
  testString_count = 0
  testString_start = Date.now()
  console.log("testString 1 sequence start")
  testString = !->
    clientB.RpcAsync "testString", _t_str, (err, ret)!->
      testString_count++
      if testString_count < testString_count_max
        if testString_count % 10000 ~= 0
          diffTime = Date.now() - testString_start
          speed = Math.round testString_count / (diffTime / 1000)
#          console.log("testString_count = #{testString_count} , speed = #{speed}/s")
        testString()
      else
        testString_end = Date.now()
        diffTime = Date.now() - testString_start
        speed = Math.round _test_count / (diffTime / 1000)
        console.log("testString 1 sequence finished, count = #{_test_count}, time = #{diffTime}ms, speed = #{speed}/s")
  testString()
, 1000 * 1)

setTimeout(!->
  testJson_count_max = _test_count
  testJson_count = 0
  testJson_start = Date.now()
  console.log("testJson 1 sequence start")
  testJson = !->
    clientB.RpcAsync "testJson", _t_json, (err, ret)!->
      testJson_count++
      if testJson_count < testJson_count_max
        if testJson_count % 10000 ~= 0
          diffTime = Date.now() - testJson_start
          speed = Math.round testJson_count / (diffTime / 1000)
#          console.log("testJson_count = #{testJson_count} , speed = #{speed}/s")
        testJson()
      else
        testJson_end = Date.now()
        diffTime = Date.now() - testJson_start
        speed = Math.round _test_count / (diffTime / 1000)
        console.log("testJson 1 sequence finished, count = #{_test_count}, time = #{diffTime}ms, speed = #{speed}/s")
  testJson()
, 1000 * 15)

setTimeout(!->
  testString_count_max = _test_count
  testString_count = 0
  testString_start = Date.now()
  console.log("testString #{_sequence_count} sequence start")
  consoleEndPrinted = false
  testString = !->
    clientB.RpcAsync "testString", _t_str, (err, ret)!->
      testString_count++
      if testString_count < testString_count_max
#        if testString_count % 10000 ~= 0
#          diffTime = Date.now() - testString_start
#          speed = testString_count / (diffTime / 1000)
#          console.log("testString_count = #{testString_count} , speed = #{speed}/s")
        testString()
      else
        if !consoleEndPrinted
          consoleEndPrinted := true
          testString_end = Date.now()
          diffTime = Date.now() - testString_start
          speed = Math.round _test_count / (diffTime / 1000)
          console.log("testString #{_sequence_count} sequence finished, count = #{_test_count}, time = #{diffTime}ms, speed = #{speed}/s")
  for til _sequence_count
    testString()
, 1000 * 30)

setTimeout(!->
  testJson_count_max = _test_count
  testJson_count = 0
  testJson_start = Date.now()
  console.log("testJson #{_sequence_count} sequence start")
  consoleEndPrinted = false
  testJson = !->
    clientB.RpcAsync "testJson", _t_json, (err, ret)!->
      testJson_count++
      if testJson_count < testJson_count_max
#        if testJson_count % 1000 ~= 0
#          diffTime = Date.now() - testJson_start
#          speed = testJson_count / (diffTime / 1000)
#          console.log("testJson_count = #{testJson_count} , speed = #{speed}/s")
        testJson()
      else
        if !consoleEndPrinted
          consoleEndPrinted := true
          testJson_end = Date.now()
          diffTime = Date.now() - testJson_start
          speed = Math.round _test_count / (diffTime / 1000)
          console.log("testJson #{_sequence_count} sequence finished, count = #{_test_count}, time = #{diffTime}ms, speed = #{speed}/s")
  for til _sequence_count
    testJson()
, 1000 * 45)




