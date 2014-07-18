Promise = require "bluebird"
chains = require "./chains"
debug = require("debug")("bluebird-chains")

Promise.chains = {
  concat: (arr, initVal) ->
    return new Promise (resolve, reject) ->
      #debug "concat start"
      chain = new chains()
      #debug "gathering arr"
      for a in arr
        chain.push a
      #debug "executing run"
      return chain.run(initVal).then resolve, reject
  collect: (arr, initVal) ->
    return new Promise (resolve, reject) ->
      #debug "concat start"
      chain = new chains()
      #debug "gathering arr"
      for a in arr
        chain.push a
      #debug "executing run"
      return chain.collect(initVal).then resolve, reject
}
module.exports = Promise
