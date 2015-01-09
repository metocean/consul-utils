get = require './httpget'

parallel = (tasks, callback) ->
  count = tasks.length
  result = (cb) ->
    return cb() if count is 0
    for task in tasks
      task ->
        count--
        cb() if count is 0
  result(callback) if callback?
  result

module.exports = (httpAddr, callback) ->
  get "#{httpAddr}/v1/catalog/services", (err, services) ->
    return callback [err] if err?
    errors = []
    results = []
    tasks = []
    for name, tags of services
      do (name, tags) ->
        tasks.push (cb) ->
          get "#{httpAddr}/v1/catalog/service/#{name}", (err, service) ->
            if err?
              errors.push err
            else
              results.push service
            cb()
    parallel tasks, ->
      return callback errors if errors.length > 0
      callback null, results