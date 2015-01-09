http = require 'http'

module.exports = (url, callback) ->
  http
    .get url, (res) ->
      data = ''
      res.setEncoding 'utf8'
      res.on 'data', (chunk) -> data += chunk
      res.on 'end', ->
        data = JSON.parse data
        callback null, data
    .on 'error', callback