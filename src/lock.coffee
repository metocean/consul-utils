httpput = require './httpput'
url_parse = require('url').parse
qs = require 'querystring'

module.exports = (httpAddr, key) ->
  haslock = no

  if typeof httpAddr is 'string'
    if httpAddr.indexOf('http://') isnt 0
      httpAddr = "http://#{httpAddr}"
    httpAddr = url_parse httpAddr

  paramsforurl = (url) ->
    hostname: httpAddr.hostname
    port: httpAddr.port
    path: "/v1/kv/#{url}"
    method: 'PUT'

  isvalid: -> haslock

  acquire: (session, contents, cb) ->
    params = paramsforurl "#{key}?#{qs.stringify acquire: session}"
    httpput params, contents, (err, result) ->
      if err?
        haslock = no
        console.error "Trying to acquire lock #{key}"
        console.error err
        cb haslock if cb?
        return
      haslock = result
      cb haslock if cb?

  release: (session, contents, cb) ->
    haslock = no
    if !session?
      cb yes if cb?
      return
    params = paramsforurl "#{key}?#{qs.stringify release: session}"
    httpput params, contents, (err, result) ->
      if err?
        console.error "Trying to release lock #{key}"
        console.error err
        cb no if cb?
        return
      cb result if cb?
