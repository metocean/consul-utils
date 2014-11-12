module.exports = class DiffPool
  constructor: (callback) ->
    @_items = []
    @_callback = callback
  
  members: => @_items
  
  set: (items) =>
    removed = @_items[..]
    next = []
    added = []
    
    for i in items
      found = null
      for e in removed
        alltrue = yes
        for key, value of i
          if value isnt e[key]
            alltrue = no
            break
        
        if alltrue
          found = e
          break
      
      if found?
        index = removed.indexOf found
        removed.splice index, 1
        next.push found
        continue
      
      next.push i
      added.push i
    
    @_items = next
    
    if @_callback? and added.length isnt 0 or removed.length isnt 0
      @_callback added, removed