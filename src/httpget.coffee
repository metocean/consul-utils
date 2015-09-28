http = require 'http'

module.exports = (url, cb) ->
  if typeof url is 'string'
    url = "http://#{url}" if url.indexOf('http://') isnt 0
  http
    .get url, (res) ->
      data = ''
      res.setEncoding 'utf8'

      if res.statusCode is 404
        res.on 'data', ->
        return res.on 'end', -> cb null, null

      if res.statusCode isnt 200
        error = ''
        res.on 'data', (data) -> error += data
        return res.on 'end', -> cb error

      res.on 'data', (chunk) -> data += chunk
      res.on 'end', ->
        data = JSON.parse data
        cb null, data
    .on 'error', cb