require('source-map-support').install() ;

var app = module.exports = require('express')();
require('expo')(app, __dirname);
require('expo-sequelize')(app);
require('expo-connect_assets')(app);

global.util = require('util');
global.inspect = require('util').inspect;
