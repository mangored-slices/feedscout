var app = require('../..');
var Sq = require('sequelize');

var Entry = app.sequelize().define('Entry', {
  accountId: Sq.STRING,
  postType: Sq.STRING,
  imageUrl: Sq.STRING,
  content: Sq.TEXT,
  fullContent: Sq.TEXT
});

module.exports = Entry;

var Account = require('./account');
Account.hasMany(Entry);
Entry.belongsTo(Account);
