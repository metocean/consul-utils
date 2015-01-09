get = require './httpget'

module.exports = (httpAddr, callback) ->
  get "#{httpAddr}/v1/agent/services", callback