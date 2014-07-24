Promise = require 'bluebird'
util = require 'util'

debug = require("debug")("chains:main")

isFunction = (functionToCheck) ->
  return functionToCheck && ({}).toString.call(functionToCheck) is '[object Function]'


class Chains
  constructor: () ->
    @data = []

  push: (func, args, context) =>
    if !isFunction(func)
      throw "Unable to add promise as it is not a function, functions are require for delayed execution"
    @data.push { func: func, args: args, context: context }


  last: () ->
    return @run(arguments, true)

  collect: () ->
    return @run(arguments, false)

  run: (args, concat) =>
    return new Promise (resolve, reject) =>
      collect = []
      return @loops(@data.slice(0), args, concat, collect)
        .then(resolve, reject)
        .catch (e) ->
          debug "run error", e
          reject(e)

  loops: (data, args, concat = false, collect) =>
    return new Promise (resolve, reject) =>
      onComplete = (a) =>
        if a?
          collect.push a
        debug "execute complete"
        @loops(data, arguments, concat, collect)
          .then(resolve, reject)
          .catch (e) ->
            debug "error caught", e
            reject(e)
      p = data.shift()
      if p?
        debug "executing promise function"
        if p.args?
          args = p.args

        return p.func.apply(p.context, args)
            .then(onComplete, reject)
            .catch (e) ->
              debug "error caught", e
              reject(e)

      debug "finished", collect.length, concat, collect

      if concat
        return resolve(collect[collect.length-1])
      else
        return resolve(collect)

module.exports = Chains
