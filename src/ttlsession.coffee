Session = require './session'

module.exports = (httpaddr, options) ->
  options ?= {}
  options.ttl ?= 10
  tickinterval = options.ttl * 1000
  options.ttl = "#{options.ttl}s"

  session = Session httpaddr, options

  timeout = null
  onup = null
  ondown = null

  createsession = ->
    #console.log 'create session'
    session.create (success) ->
      if !success
        ondown()
        console.error "Retrying in #{options.ttl}"
        timeout = setTimeout createsession, tickinterval
        return
      timeout = setTimeout renewsession, tickinterval
      onup()

  renewsession = ->
    #console.log 'renew session'
    session.renew (success) ->
      if !success
        ondown()
        console.error "Retrying in #{options.ttl}"
        timeout = setTimeout createsession, tickinterval
        return
      timeout = setTimeout renewsession, tickinterval
      onup()

  run: (options) ->
    onup = options.onup ? ->
    ondown = options.ondown ? ->
    return console.error 'Already running' if timeout?
    createsession()

  destroy: (cb) ->
    clearTimeout timeout if timeout?
    if !session.isvalid()
      cb() if cb?
      return
    session.destroy (success) ->
      if !success
        console.error 'Session unable to be destroyed'
      ondown()
      cb() if cb?

  isvalid: session.isvalid
  id: session.id
