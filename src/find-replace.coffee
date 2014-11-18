http = require 'http'
url_parse = require('url').parse

findreplace = (httpAddr, key, find, replace, callback) ->
  getparams =
    hostname: httpAddr.hostname
    port: httpAddr.port
    path: "/v1/kv/#{key}"
  
  @_httpRequest = http.get getparams, (res) ->
    res.setEncoding 'utf8'
    if res.statusCode isnt 200
      error = ''
      res.on 'data', (data) -> error += data
      return res.on 'end', ->
        console.log "Error updating #{key}"
        console.log
          code: res.statusCode
          error: error
        callback()
  
    content = ''
    res.on 'data', (data) => content += data
    res.on 'end', =>
      result = JSON.parse content
      buf = new Buffer result[0].Value, 'base64'
      result = buf.toString()
      result = result.replace new RegExp(find, 'g'), replace
      
      putparams =
        hostname: httpAddr.hostname
        port: httpAddr.port
        path: "/v1/kv/#{key}"
        method: 'PUT'
      
      req = http.request putparams, (res) ->
        res.setEncoding 'utf8'
        if res.statusCode isnt 200
          error = ''
          res.on 'data', (data) -> error += data
          return res.on 'end', ->
            console.log "Error updating #{key}"
            console.log
              code: res.statusCode
              error: error
            callback()
        
        res.on 'data', ->
        res.on 'end', ->
          console.log "Updated #{key}"
          callback()
        
      req.write result
      req.end()

module.exports = (httpAddr, keys, find, replace, callback) ->
  find = find.replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'
  
  if typeof httpAddr is 'string'
    httpAddr = "http://#{httpAddr}" if httpAddr.indexOf('http://') isnt 0
    httpAddr = url_parse httpAddr
  
  count = 0
  
  for key in keys
    findreplace httpAddr, key, find, replace, ->
      count++
      callback() if count is keys.length