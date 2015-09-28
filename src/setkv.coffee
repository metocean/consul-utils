httpput = require './httpput'
url_parse = require('url').parse

module.exports = (httpAddr, url, contents, cb) ->
  if typeof httpAddr is 'string'
    if httpAddr.indexOf('http://') isnt 0
      httpAddr = "http://#{httpAddr}"
    httpAddr = url_parse httpAddr

  params =
    hostname: httpAddr.hostname
    port: httpAddr.port
    path: "/v1/kv/#{url}"
    method: 'PUT'

  httpput params, contents, cb