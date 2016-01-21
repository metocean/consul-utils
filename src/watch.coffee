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
      recurse: no

    if typeof options is 'function'
      callback = options
      options = null

    @_options.wait = options.wait if options?.wait?
    @_options.recurse = options.recurse if options?.recurse?
    @_options.retry = options.retry if options?.retry?

    if typeof service is 'string'
      service = "http://#{service}" if service.indexOf('http://') isnt 0
      service = url_parse service

    @_service = service
    @_callback = callback
    @_request()

    @_timeout = null

  _request: =>
    @_timeout = null

    query = qs.parse @_service.query
    query.wait = "#{@_options.wait}s"
    query.index = @_index if @_index?
    query.recurse = null if @_options.recurse

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

        if res.statusCode isnt 200
          error = ''
          res.on 'data', (data) => error += data
          return res.on 'end', => @_handleError
            code: res.statusCode
            error: error

        content = ''
        res.on 'data', (data) => content += data
        res.on 'end', =>
          data = JSON.parse content
          @_callback data if data?
          @_tick res.headers['x-consul-index']
      .on 'error', (e) => @_handleError e

  _tick: (index) =>
    delete @_had404
    @_index = index
    return if @_fin? and @_fin
    @_timeout = setTimeout @_request, 0

  _handleError: (error) =>
    return if @_fin? and @_fin
    console.error "Consul Error. Retrying in #{@_options.retry} seconds..."
    console.error error
    @_timeout = setTimeout @_request, @_options.retry * 1000

  _handle404: =>
    if !@_had404?
      console.log "Consul 404 #{@_service.href}. Silently retrying every #{@_options.retry} seconds..."
      @_had404 = yes
    @_timeout = setTimeout @_request, @_options.retry * 1000

  end: =>
    clearTimeout @_timeout if @_timeout?
    @_fin = yes
    if @_httpRequest?
      @_httpRequest.abort()
      @_httpRequest = null