Promise = require 'bluebird'
util = require 'util'

debug = require("debug")("bluebird-chains:main")

isFunction = (functionToCheck) ->
  return functionToCheck && ({}).toString.call(functionToCheck) is '[object Function]'


class Chains
  constructor: (@data = [], @options = {collect: false}) ->

  push: (promise) =>
    if !isFunction(promise) and !(promise instanceof Promise)
      throw "Unable to add promise as it is not a function nor is it a promise"
    @data.push promise

  run: () =>
    args = arguments
    return new Promise (resolve, reject) =>
      @collect = []
      return @loops(@data, args, true)
      #eturn Chains.ex(@data, args, 0, false, @options.collect, [])
        .then resolve, reject
  collect: () =>
    args = arguments
    return new Promise (resolve, reject) =>
      @collect = []
      return @loops(@data, args, false)
      #return Chains.ex(@data, args, 0, false, true, [])
        .then resolve, reject

  loops: (data, args,concat = false) =>
    return new Promise (resolve, reject) =>
      onComplete = (a) =>
        @collect.push a
        debug "execute complete", arguments, @collect
        @loops(data, arguments, concat).then resolve, reject
      p = data.shift()
      if p?
        if isFunction(p)
          debug "executing promise function", args
          return p.apply(undefined, args).then onComplete, reject
        if p instanceof Promise
          debug "executing promise"
          return p.then onComplete, reject

      debug "finished", @collect, concat
      if concat
        return resolve(@collect[@collect.length-1])
      else
        return resolve(@collect)


  @ex: (data, args, index = 0, rejected = false, collect = false, collection = []) ->
    return new Promise (resolve, reject) ->
      onComplete = (d) =>
        debug "onComplete", d
        if collect and d?
          collection.push d
        return Chains.ex(data, arguments, index+1, rejected, collect, collection)
          .then resolve, reject

      onReject = () =>
        debug "onReject", arguments
        rejected = true
        return onComplete.apply @, arguments

      if data[index]?
        if isFunction(data[index])
          debug "executing promise function", args
          return data[index].apply(undefined, args).then onComplete, onReject
        if data[index] instanceof Promise
          debug "executing promise"
          return data[index].then onComplete, onReject
        debug "isNotAFunction isNotAPromise", data[index]
        throw "KABOOM"
      else
        if rejected
          if collect
            return reject(collection)
          else
            return reject.apply(undefined, args)
        else
          if collect
            return resolve(collection)
          else
            return resolve.apply(undefined, args)
module.exports = Chains
