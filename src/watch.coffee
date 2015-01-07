http = require 'http'
url_parse = require('url').parse
qs = require 'querystring'

module.exports = class Watch
  # options is optional
  constructor: (service, options, callback) ->
    # defaults
    @_options =
      wait: 10000
      retry: 10
    
    if typeof options is 'function'
      callback = options
      options = null
    
    @_options.wait = options.wait if options?.wait?
    @_options.retry = options.retry if options?.retry?
    
    if typeof service is 'string'
      service = "http://#{service}" if service.indexOf('http://') isnt 0
      service = url_parse service
    
    @_service = service
    @_callback = callback
    @_request()
  
  _request: =>
    query = qs.parse @_service.query
    query.wait = "#{@_options.wait}s"
    query.index = @_index if @_index?
    
    params =
      hostname: @_service.hostname
      port: @_service.port
      path: "#{@_service.pathname}?#{qs.stringify query}"
      # long polling so shouldn't pool
      agent: no
    
    @_httpRequest = http
      .get params, (res) =>
        res.setEncoding 'utf8'
        if res.statusCode is 404
          res.on 'data', ->
          return res.on 'end', => @_handle404()
        
        if res.statusCode is 500
          error = ''
          res.on 'data', (data) => error += data
          return res.on 'end', => @_handleError error
        
        if res.statusCode isnt 200
          error = ''
          res.on 'data', (data) => error += data
          return res.on 'end', => @_handleError
            code: res.statusCode
            error: error
        
        res.on 'data', (data) => @_callback JSON.parse data
        res.on 'end', => @_tick res.headers['x-consul-index']
      .on 'error', (e) => @_handleError e
  
  _tick: (index) =>
    delete @_had404
    @_index = index
    return if @_fin? and @_fin
    setTimeout @_request, 0
  
  _handleError: (error) =>
    return if @_fin? and @_fin
    console.error 'Consul <-> RedWire error'
    console.error error
    console.error "Retrying in #{@_options.retry} seconds..."
    setTimeout @_request, @_options.retry * 1000
  
  _handle404: =>
    if !@_had404?
      console.log "Consul <-> RedWire 404 #{@_service.href}"
      console.log "Silently retrying every #{@_options.retry} seconds..."
      @_had404 = yes
    setTimeout @_request, @_options.retry * 1000
  
  end: =>
    @_fin = yes
    @_httpRequest.abort() if @_httpRequest?