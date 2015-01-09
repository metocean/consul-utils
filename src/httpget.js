// Generated by CoffeeScript 1.8.0
var http;

http = require('http');

module.exports = function(url, callback) {
  return http.get(url, function(res) {
    var data;
    data = '';
    res.setEncoding('utf8');
    res.on('data', function(chunk) {
      return data += chunk;
    });
    return res.on('end', function() {
      data = JSON.parse(data);
      return callback(null, data);
    });
  }).on('error', callback);
};