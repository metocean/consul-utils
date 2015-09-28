http = require 'http'
url_parse = require('url').parse

httpput = (params, content, cb) ->
  req = http.request params, (res) ->
    res.setEncoding 'utf8'
    if res.statusCode isnt 200
      error = ''
      res.on 'data', (data) -> error += data
      return res.on 'end', -> cb error
    body = ''
    res.on 'data', (data) -> body += data
    res.on 'end', -> cb null, JSON.parse body
  req.on 'error', cb
  if content?
    content = JSON.stringify content
    req.setHeader 'Content-Type', 'application/json'
    req.setHeader 'Content-Length', Buffer.byteLength content
    req.write content
  req.end()

module.exports = (httpAddr, options) ->
  options ?= {}
  opts = {}
  if options.name?
    opts.Name = options.name
  if options.lockdelay?
    opts.LockDelay = options.lockdelay
  if options.node?
    opts.Node = options.node
  if options.checks?
    opts.Checks = options.checks
  if options.behavior?
    opts.Behavior = options.behavior
  if options.ttl?
    opts.TTL = options.ttl
  if typeof httpAddr is 'string'
    httpAddr = "http://#{httpAddr}" if httpAddr.indexOf('http://') isnt 0
    httpAddr = url_parse httpAddr

  paramsforurl = (url) ->
    hostname: httpAddr.hostname
    port: httpAddr.port
    path: url
    method: 'PUT'

  id = null

  isvalid: -> id?
  id: -> id

  create: (cb) ->
    if id?
      console.error 'Already created'
      return cb no
    params = paramsforurl '/v1/session/create'
    httpput params, opts, (err, result) ->
      if err?
        console.error 'Trying to create session'
        console.error err
        return cb no
      id = result.ID
      cb yes

  renew: (cb) ->
    if !id?
      console.error 'No session found'
      return cb no
    params = paramsforurl "/v1/session/renew/#{id}"
    httpput params, null, (err) ->
      if err?
        console.error "Trying to renew session #{id}"
        console.error err
        cb no
        id = null
        return
      cb yes

  destroy: (cb) ->
    if !id?
      console.error 'No session found'
      return cb no
    params = paramsforurl "/v1/session/destroy/#{id}"
    httpput params, null, (err) ->
      if err?
        console.error "Trying to destroy session #{id}"
        console.error err
        return cb no
      cb yes
      id = null
