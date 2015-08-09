Promise = require 'native-or-bluebird'
util = require 'util'

debug = require("debug")("bluebird-chains")

isFunction = (functionToCheck) ->
  return functionToCheck && ({}).toString.call(functionToCheck) is '[object Function]'

# Chains
# @example Parsing custom arguments to each promise
#   Promise = require "native-or-bluebird"
#   Chains = require "bluebird-chains"
#   func = (arg1, arg2) ->
#     return new Promise (resolve, reject) ->
#       console.log "args", arg1, arg2
#       return resolve()
#   promises = new Chains()
#   array = [1,2,3]
#   for i in [0...array.length]
#     promises.push func, [i, i+1]
#   promises.run().then () ->
#     console.log "finished"
class Chains
  # Contruct a new bluebird-chains class
  constructor: () ->
    @data = []
  # Push a new promise into the array
  # @param func [Function] function pointer to execute.
  # @param args [Array] optional arguments to provide to function, otherwise arguments will be the provided by the run function or the prior resolve statement (depending where the function is in the array). Using this will override any args reference from last, collect or run
  # @param context [Object] optional context object aka what [this] will be set to when executing.
  push: (func, args, context) =>
    if !isFunction(func)
      throw "Unable to add promise as it is not a function, functions are require for delayed execution"
    @data.push { func: func, args: args, context: context }

  # collect is an execution function, it will trigger the promise waterfall and return the last resolve parameters as the arguments for the then function.
  # @param all [arguments] all arguments provided will be supplied to the first executing function
  # @return [Promise]
  last: () ->
    return @run(arguments, true)
  # collect is an execution function, it will trigger the promise waterfall and return an array of all resolve parameters.
  # @param all [arguments] all arguments provided will be supplied to the first executing function
  # @return [Promise]
  collect: () ->
    return @run(arguments, false)
  # run is an execution function, it will trigger the promise waterfall
  # @param args [Array] Arguments to provided to the first executing function
  # @param concat [Boolean] True to provided the last result as an array of all results or False for just the last one
  # @return [Promise]
  run: (args, concat) =>
    return new Promise (resolve, reject) =>
      collect = []
      return @loops(@data.slice(0), args, concat, collect)
        .then(resolve, reject)
        .catch (e) ->
          debug "run error", e
          reject(e)
  # Do Not Use - loops is the smarts of this library this should never be access external, refer to last, collect, or run
  # @private
  # @param data [Array] This a index based array of promises to be executed
  # @param args [Array] arguments to be supplied to the next function to execute
  # @param concat [Boolean] True to concat results and provide at end of execution tree
  # @param collect [Array] object that holds the collected results of the executed promises
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
