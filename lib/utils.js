module.exports = {
  sha512: sha512,
  hashify: hashify,
  wrap: wrap,
  setter: setter
};

function sha512(str) {
  return require('crypto').createHash('sha512').update(str).digest('hex');
}

function hashify(str) {
  var crypto = require('crypto');
  var algo = crypto.createHash('sha512');
  var key = sha512('bummer') + sha512('squeeze');
  var hmac = crypto.createHmac(algo, key);
  return hmac.update(str).digest('hex');
}

/*
 * Wraps a promise
 */
function wrap(promise, callback) {
  promise.then(
    function(data) { callback(null, data); },
    function(err) { callback(err); });
}

/*
 * Creates a setter callback
 */
function setter(attr, req, next) {
  return function(err, data) {
    if (err) return next(err);

    req.locals[attr] = data;
    next();
  };
}
