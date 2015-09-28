Watch = require './watch'
qs = require 'querystring'

module.exports = class WatchSession
  constructor: (httpAddr, session, options, callback) ->
    if !callback?
      callback = options
      options = {}
    @_watch = new Watch "#{httpAddr}/v1/session/info/#{session}", options, (configurations) =>
      for configuration in configurations
        if configuration.Value?
          buf = new Buffer configuration.Value, 'base64'
          configuration.Value = buf.toString()
      callback configurations

  end: => @_watch.end()
