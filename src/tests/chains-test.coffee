
Promise = require "bluebird"
Chains = require "../index"
expect = require('chai').expect

debug = require("debug")("chains:tests")

getRandomArbitrary = (min, max) ->
  return Math.random() * (max - min) + min

describe 'Testing Chains', () ->
  it 'concurrency consistancy check', () ->
    len = 5
    p = new Chains
    initData = 10
    argData = 29
    p.push (data) ->
      return new Promise (resolve, reject) ->
        data = data / 2
        resolve(data)
    p.push (data) ->
      return new Promise (resolve, reject) ->
        ex = () ->
          r = new Promise (res, rej) ->
            data = data + 2
            res(data)
          r.then resolve, reject
        setTimeout(ex, getRandomArbitrary(0, 500))
    , [argData]
    p.push (data) ->
      return new Promise (resolve, reject) ->
        data = data * 3
        resolve(data)
    debug "start"
    p.last(initData).then (result) ->
      debug "end", result
      expect(result).to.equal((argData + 2) * 3)

  it 'Last test with functions', () ->
    len = 5
    p = new Chains
    count = 0
    for i in [0...len]
      p.push (a = 0) ->
        return new Promise (resolve, reject) ->
          ex = () ->
            v = new Promise (rs, rj) ->
              debug "in", a
              expect(count).to.equal(a)
              count++
              c = a + 1
              debug "out",  c
              resolve(c)
            v.then resolve, reject
          setTimeout(ex, getRandomArbitrary(0, 200))
    debug "start"
    p.last(0).then (result) ->
      debug "end"
      expect(result).to.equal(len)
      expect(p.data.length).to.equal(len)
