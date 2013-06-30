require('q').longStackSupport = true;

var app = module.exports = require('express')();
require('expo')(app, __dirname);
require('expo-sequelize')(app);
require('expo-connect_assets')(app);

global.util = require('util');
global.inspect = require('util').inspect;

// Listen when invoked as `node .` or `node app.js`
if (!module.parent) {
  var port = process.env.PORT || 3000;
  app.log.debug("Listening at port " + port);
  app.load().listen(port);
}
