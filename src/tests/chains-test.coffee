Promise = require "../index"
expect = require('chai').expect

debug = require("debug")("bluebird-chains:tests")



describe 'Testing Chains', () ->
  it 'Concat test with functions', () ->
    len = 30
    p = []
    for i in [0...len]
      p.push (a = 0) ->
        #debug "lol", arguments
        return new Promise (resolve, reject) ->
          resolve(a+1)
    Promise.chains.concat(p, 0).then (result) ->
      expect(result).to.equal(len)

  it 'Concat test with promises', () ->
    len = 30
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
    len = 30
    p = []
    i = 0
    for i in [0...len]
      p.push new Promise (resolve, reject) ->
        i++
        resolve(i)
    Promise.chains.collect(p).then (result) ->
      debug "fin", result
      expect(result.length).to.equal(len)
