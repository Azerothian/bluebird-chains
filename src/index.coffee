Promise = require "bluebird"
chains = require "./chains"
debug = require("debug")("bluebird-chains:index")

Promise.chains = {
  concat: (arr, initVal) ->
    return new Promise (resolve, reject) ->
      debug "concat start"
      chain = new chains()
      debug "gathering arr"
      for a in arr
        chain.push a
      debug "executing run", chain.data.length
      return chain.run(initVal).then resolve, reject
  collect: (arr, initVal) ->
    return new Promise (resolve, reject) ->
      debug "collect start"
      chain = new chains()
      debug "gathering arr"
      for a in arr
        chain.push a
      debug "executing run", chain.data.length
      return chain.collect(initVal).then resolve, reject
}
module.exports = Promise
