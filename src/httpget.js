// Generated by CoffeeScript 1.9.2
var http;

http = require('http');

module.exports = function(url, cb) {
  if (typeof url === 'string') {
    if (url.indexOf('http://') !== 0) {
      url = "http://" + url;
    }
  }
  return http.get(url, function(res) {
    var data, error;
    data = '';
    res.setEncoding('utf8');
    if (res.statusCode === 404) {
      res.on('data', function() {});
      return res.on('end', function() {
        return cb(null, null);
      });
    }
    if (res.statusCode !== 200) {
      error = '';
      res.on('data', function(data) {
        return error += data;
      });
      return res.on('end', function() {
        return cb(error);
      });
    }
    res.on('data', function(chunk) {
      return data += chunk;
    });
    return res.on('end', function() {
      data = JSON.parse(data);
      return cb(null, data);
    });
  }).on('error', cb);
};
