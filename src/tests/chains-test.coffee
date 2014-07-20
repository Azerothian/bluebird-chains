Promise = require "../index"
expect = require('chai').expect

debug = require("debug")("bluebird-chains:tests")

getRandomArbitrary = (min, max) ->
  return Math.random() * (max - min) + min

describe 'Testing Chains', () ->
  it 'concurrency consistancy check', () ->
    len = 5
    p = []
    initData = 10
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
    p.push (data) ->
      return new Promise (resolve, reject) ->
        data = data * 3
        resolve(data)
    Promise.chains.concat(p, initData).then (result) ->
      expect(result).to.equal(((initData / 2) + 2) * 3)

  it 'Concat test with functions', () ->
    len = 5
    p = []
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
    Promise.chains.concat(p, 0).then (result) ->
      expect(result).to.equal(len)

  it 'Concat test with promises', () ->
    len = 2
    p = []
    i = 0
    for i in [0...len]
      p.push new Promise (resolve, reject) ->
        i++
        resolve(i)
    Promise.chains.concat(p).then (result) ->
      debug "fin", result
      expect(result).to.equal(len)
  it 'Collect test with promises', () ->
    len = 2
    p = []
    i = 0
    for i in [0...len]
      p.push new Promise (resolve, reject) ->
        i++
        resolve(i)
    Promise.chains.collect(p).then (result) ->
      debug "fin", result
      expect(result.length).to.equal(len)
