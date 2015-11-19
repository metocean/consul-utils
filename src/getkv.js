// Generated by CoffeeScript 1.9.2
var get;

get = require('./httpget');

module.exports = function(httpAddr, key, cb) {
  return get(httpAddr + "/v1/kv/" + key, function(err, results) {
    var buf, i, len, result;
    if (err != null) {
      return cb(err);
    }
    if (results == null) {
      return cb(null, []);
    }
    for (i = 0, len = results.length; i < len; i++) {
      result = results[i];
      if (result.Value == null) {
        continue;
      }
      buf = new Buffer(result.Value, 'base64');
      result.Value = buf.toString();
    }
    return cb(null, results);
  });
};