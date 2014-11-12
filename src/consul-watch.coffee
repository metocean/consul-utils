http = require 'http'
url_parse = require('url').parse

module.exports = class ConsulWatch
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
    params =
      hostname: @_service.hostname
      port: @_service.port
      path: "#{@_service.href}?wait=#{@_options.wait}s"
      # long polling so shouldn't pool
      agent: no
    
    params.path += "&index=#{@_index}" if @_index?
    
    http
      .get params, (res) =>
        res.setEncoding 'utf8'
        if res.statusCode isnt 200
          error = ''
          res.on 'data', (data) => error += data
          res.on 'end', => @_handleError error
          return
        
        res.on 'data', (data) => @_callback JSON.parse data
        res.on 'end', => @_tick res.headers['x-consul-index']
      .on 'error', (e) => @_handleError e
  
  _tick: (index) =>
    @_index = index
    return if @_fin? and @_fin
    setTimeout @_request, 0
  
  _handleError: (error) =>
    console.error 'Consul <-> RedWire error'
    console.error error
    console.error "Retrying in #{@_options.retry} seconds..."
    setTimeout @_request, @_options.retry * 1000
  
  end: =>
    @_fin = yes