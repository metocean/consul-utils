Watch = require './watch'
qs = require 'querystring'

console.log qs.encode {}

module.exports = class KV
  constructor: (httpAddr, key, options, callback) ->
    if !callback?
      callback = options
      options = {}
    @_watch = new Watch "#{httpAddr}/v1/kv/#{key}", options, (configurations) =>
      for configuration in configurations
        if configuration.Value?
          buf = new Buffer configuration.Value, 'base64'
          configuration.Value = buf.toString()
      callback configurations
  
  end: => @_watch.end()