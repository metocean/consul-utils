consul = require './'
hub = require 'odo-hub'
hub = hub.create()

worker = (httpAddr, prefix) ->
  session = consul.TTLSession httpAddr
  watch = new consul.KV httpAddr, prefix, { recurse: yes }, (keys) ->
    keys = keys.filter (k) -> k.Key isnt prefix
    console.log keys

  # lock = consul.Lock httpAddr, 'test_lock'


  # haslock = no
  # trylock = ->
  #   return if haslock
  #   lock.acquire session.id(), (success) ->
  #     if success
  #       console.log 'received lock, happy'
  #       haslock = yes
  #       cancelwaitingforlock()
  #       return
  #     waitforlock()

  # getlock = null
  # waitforlock = ->
  #   return if watchlock?
  #   getlock = consul.GetKV 'docker:8500', 'test_lock', (err, results) ->
  #     console.log results
  # cancellock = ->
  #   haslock = no
  # cancelwaitingforlock = ->
  #   if getlock?
  #     getlock.abort()
  #     getlock = null

  session.run
    onup: ->
      # trylock()
      console.log 'onup'
    ondown: ->
      # cancellock()
      # cancelwaitingforlock()
      console.log 'ondown'

  destroy: ->
    session.destroy()
    watch.end()

worker = worker 'docker:8500', 'sagas/'

process.on 'SIGINT', ->
  worker.destroy()
