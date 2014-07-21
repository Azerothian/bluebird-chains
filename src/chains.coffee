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
      throw "Unable to add promise as it is not a function"
    @data.push { func: func, args: args, context: context }


  last: () ->
    return @run(arguments, true)

  collect: () ->
    return @run(arguments, false)

  run: (args, concat) =>
    return new Promise (resolve, reject) =>
      collect = []
      return @loops(@data.slice(0), args, concat, collect)
        .then resolve, reject

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
      p = data.shift()
      if p?
        debug "executing promise function"
        if p.args?
          args = p.args

        return p.func.apply(p.context, args)
            .then(onComplete, reject)
            .catch (e) ->
              debug "error caught", e


      debug "finished", collect.length, concat, collect

      if concat
        return resolve(collect[collect.length-1])
      else
        return resolve(collect)

module.exports = Chains

###

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
      #return Chains.ex(@data, args, 0, false, @options.collect, [])
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
        if a?
          @collect.push a
        debug "execute complete"
        @loops(data, arguments, concat)
          .then(resolve, reject)
          .catch (e) ->
            debug "error caught", e
      p = data.shift()
      if p?
        if isFunction(p)
          debug "executing promise function"
          return p.apply(undefined, args)
            .then(onComplete, reject)
            .catch (e) ->
              debug "error caught", e
        if p instanceof Promise
          debug "executing promise"
          return p.then(onComplete, reject)
            .catch (e) ->
              debug "error caught", e

      debug "finished", @collect.length, concat
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
###
