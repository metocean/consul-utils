http = require 'http'

module.exports = (params, content, cb) ->
  req = http.request params, (res) ->
      res.setEncoding 'utf8'
      if res.statusCode isnt 200
        error = ''
        res.on 'data', (data) -> error += data
        return res.on 'end', -> cb error
      body = ''
      res.on 'data', (data) -> body += data
      res.on 'end', -> cb null, JSON.parse body
    .on 'error', cb
  if content?
    req.setHeader 'Content-Type', 'application/json'
    req.setHeader 'Content-Length', Buffer.byteLength content
    req.write content
  req.end()