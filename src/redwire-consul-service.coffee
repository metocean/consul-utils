ConsulWatch = require './consul-watch'
DiffPool = require './diff-pool'

module.exports = class RedWireConsulService
  constructor: (httpAddr, serviceId, callback) ->
    @_index = 0
    @_pool = new DiffPool callback
    @_watch = new ConsulWatch "#{httpAddr}/v1/catalog/service/#{serviceId}", (services) =>
      @_pool.set services.map (s) ->
        host: s.Node
        address: s.Address
        port: s.ServicePort
  
  end: => @_watch.end()
  members: => @_pool.members()
  
  next: =>
    members = @members()
    @_index = @_index % members.length
    result = members[@_index]
    @_index++
    result
  
  distribute: => (mount, url, req, res, next) =>
    req.target = @next()
    next()