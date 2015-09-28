// Generated by CoffeeScript 1.9.2
var http, httpput, url_parse;

http = require('http');

url_parse = require('url').parse;

httpput = function(params, content, cb) {
  var req;
  req = http.request(params, function(res) {
    var body, error;
    res.setEncoding('utf8');
    if (res.statusCode !== 200) {
      error = '';
      res.on('data', function(data) {
        return error += data;
      });
      return res.on('end', function() {
        return cb(error);
      });
    }
    body = '';
    res.on('data', function(data) {
      return body += data;
    });
    return res.on('end', function() {
      return cb(null, JSON.parse(body));
    });
  });
  req.on('error', cb);
  if (content != null) {
    content = JSON.stringify(content);
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Content-Length', Buffer.byteLength(content));
    req.write(content);
  }
  return req.end();
};

module.exports = function(httpAddr, options) {
  var id, opts, paramsforurl;
  if (options == null) {
    options = {};
  }
  opts = {};
  if (options.name != null) {
    opts.Name = options.name;
  }
  if (options.lockdelay != null) {
    opts.LockDelay = options.lockdelay;
  }
  if (options.node != null) {
    opts.Node = options.node;
  }
  if (options.checks != null) {
    opts.Checks = options.checks;
  }
  if (options.behavior != null) {
    opts.Behavior = options.behavior;
  }
  if (options.ttl != null) {
    opts.TTL = options.ttl;
  }
  if (typeof httpAddr === 'string') {
    if (httpAddr.indexOf('http://') !== 0) {
      httpAddr = "http://" + httpAddr;
    }
    httpAddr = url_parse(httpAddr);
  }
  paramsforurl = function(url) {
    return {
      hostname: httpAddr.hostname,
      port: httpAddr.port,
      path: url,
      method: 'PUT'
    };
  };
  id = null;
  return {
    isvalid: function() {
      return id != null;
    },
    id: function() {
      return id;
    },
    create: function(cb) {
      var params;
      if (id != null) {
        console.error('Already created');
        return cb(false);
      }
      params = paramsforurl('/v1/session/create');
      return httpput(params, opts, function(err, result) {
        if (err != null) {
          console.error('Trying to create session');
          console.error(err);
          return cb(false);
        }
        id = result.ID;
        return cb(true);
      });
    },
    renew: function(cb) {
      var params;
      if (id == null) {
        console.error('No session found');
        return cb(false);
      }
      params = paramsforurl("/v1/session/renew/" + id);
      return httpput(params, null, function(err) {
        if (err != null) {
          console.error("Trying to renew session " + id);
          console.error(err);
          cb(false);
          id = null;
          return;
        }
        return cb(true);
      });
    },
    destroy: function(cb) {
      var params;
      if (id == null) {
        console.error('No session found');
        return cb(false);
      }
      params = paramsforurl("/v1/session/destroy/" + id);
      return httpput(params, null, function(err) {
        if (err != null) {
          console.error("Trying to destroy session " + id);
          console.error(err);
          return cb(false);
        }
        cb(true);
        return id = null;
      });
    }
  };
};
