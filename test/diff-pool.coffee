expect = require('chai').expect
DiffPool = require '../src/diff-pool'

describe 'Diff Pool', ->
  it 'should handle an empty array', ->
    passed = yes
    pool = new DiffPool (added, removed) -> passed = no
    pool.set []
    expect(passed).to.be.true()
  
  it 'should pass new items in added', ->
    passed = no
    pool = new DiffPool (added, removed) ->
      expect(added).to.have.length.of 1
      expect(removed).to.be.empty()
      passed = yes
    pool.set [{ name: 'bob' }]
    expect(passed).to.be.true()
  
  it 'should pass removed items in removed', ->
    func = ->
    pool = new DiffPool (added, removed) ->
      func added, removed
    pool.set [{ name: 'bob' }]
    passed = no
    func = (added, removed) ->
      expect(added).to.be.empty()
      expect(removed).to.have.length.of 1
      passed = yes
    pool.set []
    expect(passed).to.be.true()
  
  it 'should not callback on duplicate items', ->
    func = ->
    pool = new DiffPool (added, removed) -> func added, removed
    pool.set [{ name: 'bob' }]
    passed = yes
    func = (added, removed) -> passed = no
    pool.set [{ name: 'bob' }]
    expect(passed).to.be.true()
  
  it 'should handle added items at the same time as removed items', ->
    func = ->
    pool = new DiffPool (added, removed) -> func added, removed
    pool.set [{ name: 'bob' }]
    passed = no
    func = (added, removed) ->
      expect(added).to.have.length.of 1
      expect(removed).to.have.length.of 1
      passed = yes
    pool.set [{ name: 'sue' }]
    expect(passed).to.be.true()
  
  it 'should handle more than one diff in a row', ->
    func = ->
    pool = new DiffPool (added, removed) -> func added, removed
    pool.set [{ name: 'bob' }, { name: 'sue' }]
    passed = no
    func = (added, removed) ->
      expect(added).to.have.length.of 1
      expect(removed).to.have.length.of 1
      passed = yes
    pool.set [{ name: 'sue' }, { name: 'mary' }]
    expect(passed).to.be.true()
    passed = no
    pool.set [{ name: 'bob' }, { name: 'mary' }]
    expect(passed).to.be.true()
  
  it 'should keep members updated', ->
    pool = new DiffPool ->
    pool.set [{ name: 'bob' }, { name: 'sue' }]
    expect(pool.members()).to.have.length.of 2
    pool.set [{ name: 'bob' }, { name: 'sue' }, { name: 'mary' }]
    expect(pool.members()).to.have.length.of 3
    pool.set []
    expect(pool.members()).to.be.empty()