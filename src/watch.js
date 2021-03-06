// Generated by CoffeeScript 1.9.2
var Watch, http, qs, url_parse,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

http = require('http');

url_parse = require('url').parse;

qs = require('querystring');

module.exports = Watch = (function() {
  function Watch(service, options, callback) {
    this.end = bind(this.end, this);
    this._handle404 = bind(this._handle404, this);
    this._handleError = bind(this._handleError, this);
    this._tick = bind(this._tick, this);
    this._request = bind(this._request, this);
    this._options = {
      wait: 10000,
      retry: 10,
      recurse: false
    };
    if (typeof options === 'function') {
      callback = options;
      options = null;
    }
    if ((options != null ? options.wait : void 0) != null) {
      this._options.wait = options.wait;
    }
    if ((options != null ? options.recurse : void 0) != null) {
      this._options.recurse = options.recurse;
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
    this._timeout = null;
  }

  Watch.prototype._request = function() {
    var params, query;
    this._timeout = null;
    query = qs.parse(this._service.query);
    query.wait = this._options.wait + "s";
    if (this._index != null) {
      query.index = this._index;
    }
    if (this._options.recurse) {
      query.recurse = null;
    }
    params = {
      hostname: this._service.hostname,
      port: this._service.port,
      path: this._service.pathname + "?" + (qs.stringify(query)),
      agent: false
    };
    return this._httpRequest = http.get(params, (function(_this) {
      return function(res) {
        var content, error;
        res.setEncoding('utf8');
        if (res.statusCode === 404) {
          res.on('data', function() {});
          return res.on('end', function() {
            return _this._handle404();
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
        content = '';
        res.on('data', function(data) {
          return content += data;
        });
        return res.on('end', function() {
          var data;
          data = JSON.parse(content);
          if (data != null) {
            _this._callback(data);
          }
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
    return this._timeout = setTimeout(this._request, 0);
  };

  Watch.prototype._handleError = function(error) {
    if ((this._fin != null) && this._fin) {
      return;
    }
    console.error("Consul Error. Retrying in " + this._options.retry + " seconds...");
    console.error(error);
    return this._timeout = setTimeout(this._request, this._options.retry * 1000);
  };

  Watch.prototype._handle404 = function() {
    if (this._had404 == null) {
      console.log("Consul 404 " + this._service.href + ". Silently retrying every " + this._options.retry + " seconds...");
      this._had404 = true;
    }
    return this._timeout = setTimeout(this._request, this._options.retry * 1000);
  };

  Watch.prototype.end = function() {
    if (this._timeout != null) {
      clearTimeout(this._timeout);
    }
    this._fin = true;
    if (this._httpRequest != null) {
      this._httpRequest.abort();
      return this._httpRequest = null;
    }
  };

  return Watch;

})();
