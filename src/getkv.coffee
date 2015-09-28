get = require './httpget'

module.exports = (httpAddr, key, cb) ->
  get "#{httpAddr}/v1/kv/#{key}", (err, results) ->
    return cb err if err?
    return cb null, [] if !results?
    for result in results
      continue if !result.Value?
      buf = new Buffer result.Value, 'base64'
      result.Value = buf.toString()
    cb null, results
