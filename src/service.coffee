Watch = require './watch'
DiffPool = require './diff-pool'

module.exports = class Service
  constructor: (httpAddr, serviceId, callback) ->
    @_index = 0
    @_pool = new DiffPool callback
    @_watch = new Watch "#{httpAddr}/v1/catalog/service/#{serviceId}", (services) =>
      @_pool.set services.map (s) ->
        host: s.Node
        address: s.Address
        port: s.ServicePort
  
  end: => @_watch.end()
  members: => @_pool.members()
  
  next: =>
    members = @members()
    return null if members.length is 0
    @_index = @_index % members.length
    result = members[@_index]
    @_index++
    "#{result.address}:#{result.port}"
  
  distribute: => (mount, url, req, res, next) =>
    req.target = "http://#{@next()}"
    next()
  
  distributeHttp: => (mount, url, req, res, next) =>
    req.target = "http://#{@next()}"
    next()
  
  distributeHttps: => (mount, url, req, res, next) =>
    req.target = "https://#{@next()}"
    next()
  
  distributeWs: => (mount, url, req, socket, head, next) =>
    req.target = "http://#{@next()}"
    next()
  
  distributeTcp: => (req, socket, next) =>
    req.target = @next()
    next()
  
  distributeTls: => (req, socket, next) =>
    req.target = @next()
    next()
