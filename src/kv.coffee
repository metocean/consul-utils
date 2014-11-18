Watch = require './watch'

module.exports = class KV
  constructor: (httpAddr, key, callback) ->
    @_watch = new Watch "#{httpAddr}/v1/kv/#{key}", (configurations) =>
      for configuration in configurations
        if configuration.Value?
          buf = new Buffer configuration.Value, 'base64'
          configuration.Value = buf.toString()
      callback configurations
  
  end: => @_watch.end()