Promise = require "../index"
expect = require('chai').expect

debug = require("debug")("bluebird-chains:tests")



describe 'Testing Chains', () ->
  it 'Concat test with functions', () ->
    len = 2
    p = []
    count = 0
    for i in [0...len]
      p.push (a = 0) ->
        return new Promise (resolve, reject) ->
          ex = () ->
            debug "in", a
            expect(count).to.equal(a)
            count++
            c = a + 1
            debug "out",  c
            resolve(c)
          setTimeout(ex, 100)
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
