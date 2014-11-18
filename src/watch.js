// Generated by CoffeeScript 1.8.0
var Watch, http, url_parse,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

http = require('http');

url_parse = require('url').parse;

module.exports = Watch = (function() {
  function Watch(service, options, callback) {
    this.end = __bind(this.end, this);
    this._handle404 = __bind(this._handle404, this);
    this._handleError = __bind(this._handleError, this);
    this._tick = __bind(this._tick, this);
    this._request = __bind(this._request, this);
    this._options = {
      wait: 10000,
      retry: 10
    };
    if (typeof options === 'function') {
      callback = options;
      options = null;
    }
    if ((options != null ? options.wait : void 0) != null) {
      this._options.wait = options.wait;
    }
    if ((options != null ? options.retry : void 0) != null) {
      this._options.retry = options.retry;
    }
    if (typeof service === 'string') {
      if (service.indexOf('http://') !== 0) {
        service = "http://" + service;
      }
      service = url_parse(service);
    }
    this._service = service;
    this._callback = callback;
    this._request();
  }

  Watch.prototype._request = function() {
    var params;
    params = {
      hostname: this._service.hostname,
      port: this._service.port,
      path: "" + this._service.href + "?wait=" + this._options.wait + "s",
      agent: false
    };
    if (this._index != null) {
      params.path += "&index=" + this._index;
    }
    return this._httpRequest = http.get(params, (function(_this) {
      return function(res) {
        var error;
        res.setEncoding('utf8');
        if (res.statusCode === 404) {
          res.on('data', function() {});
          return res.on('end', function() {
            return _this._handle404();
          });
        }
        if (res.statusCode === 500) {
          error = '';
          res.on('data', function(data) {
            return error += data;
          });
          return res.on('end', function() {
            return _this._handleError(error);
          });
        }
        if (res.statusCode !== 200) {
          error = '';
          res.on('data', function(data) {
            return error += data;
          });
          return res.on('end', function() {
            return _this._handleError({
              code: res.statusCode,
              error: error
            });
          });
        }
        res.on('data', function(data) {
          return _this._callback(JSON.parse(data));
        });
        return res.on('end', function() {
          return _this._tick(res.headers['x-consul-index']);
        });
      };
    })(this)).on('error', (function(_this) {
      return function(e) {
        return _this._handleError(e);
      };
    })(this));
  };

  Watch.prototype._tick = function(index) {
    delete this._had404;
    this._index = index;
    if ((this._fin != null) && this._fin) {
      return;
    }
    return setTimeout(this._request, 0);
  };

  Watch.prototype._handleError = function(error) {
    if ((this._fin != null) && this._fin) {
      return;
    }
    console.error('Consul <-> RedWire error');
    console.error(error);
    console.error("Retrying in " + this._options.retry + " seconds...");
    return setTimeout(this._request, this._options.retry * 1000);
  };

  Watch.prototype._handle404 = function() {
    if (this._had404 == null) {
      console.log("Consul <-> RedWire 404 " + this._service.href);
      console.log("Silently retrying every " + this._options.retry + " seconds...");
      this._had404 = true;
    }
    return setTimeout(this._request, this._options.retry * 1000);
  };

  Watch.prototype.end = function() {
    this._fin = true;
    if (this._httpRequest != null) {
      return this._httpRequest.abort();
    }
  };

  return Watch;

})();
