var app = require('../..');
var Sq = require('sequelize');

var Account = app.sequelize().define('Account', {
  service: Sq.STRING
}, {
  tableName: 'accounts'
});
