// Generated by CoffeeScript 1.9.2
var DiffPool,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

module.exports = DiffPool = (function() {
  function DiffPool(callback) {
    this.set = bind(this.set, this);
    this.members = bind(this.members, this);
    this._items = [];
    this._callback = callback;
  }

  DiffPool.prototype.members = function() {
    return this._items;
  };

  DiffPool.prototype.set = function(items) {
    var added, alltrue, e, found, i, index, j, k, key, len, len1, next, removed, value;
    removed = this._items.slice(0);
    next = [];
    added = [];
    for (j = 0, len = items.length; j < len; j++) {
      i = items[j];
      found = null;
      for (k = 0, len1 = removed.length; k < len1; k++) {
        e = removed[k];
        alltrue = true;
        for (key in i) {
          value = i[key];
          if (value !== e[key]) {
            alltrue = false;
            break;
          }
        }
        if (alltrue) {
          found = e;
          break;
        }
      }
      if (found != null) {
        index = removed.indexOf(found);
        removed.splice(index, 1);
        next.push(found);
        continue;
      }
      next.push(i);
      added.push(i);
    }
    this._items = next;
    if ((this._callback != null) && added.length !== 0 || removed.length !== 0) {
      return this._callback(added, removed);
    }
  };

  return DiffPool;

})();
