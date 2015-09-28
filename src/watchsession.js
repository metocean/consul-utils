// Generated by CoffeeScript 1.9.2
var Watch, WatchSession, qs,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Watch = require('./watch');

qs = require('querystring');

module.exports = WatchSession = (function() {
  function WatchSession(httpAddr, session, options, callback) {
    this.end = bind(this.end, this);
    if (callback == null) {
      callback = options;
      options = {};
    }
    this._watch = new Watch(httpAddr + "/v1/session/info/" + session, options, (function(_this) {
      return function(configurations) {
        var buf, configuration, i, len;
        for (i = 0, len = configurations.length; i < len; i++) {
          configuration = configurations[i];
          if (configuration.Value != null) {
            buf = new Buffer(configuration.Value, 'base64');
            configuration.Value = buf.toString();
          }
        }
        return callback(configurations);
      };
    })(this));
  }

  WatchSession.prototype.end = function() {
    return this._watch.end();
  };

  return WatchSession;

})();
