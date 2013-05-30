module.exports = {
  sha512: sha512,
  hashify: hashify
};

function sha512(str) {
  return require('crypto').createHash('sha512').update(str).digest('hex');
};

function hashify(str) {
  var prefix = sha512('bummer') + sha512('squeeze');
  return sha512(prefix + str);
};
