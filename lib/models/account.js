var app = require('../..');
var Sq = require('sequelize');
var extend = require('util')._extend;

var Account = app.sequelize().define('Account', {
  name: Sq.STRING,
  service: Sq.STRING,
  credentials: { type: Sq.TEXT, defaultValue: '{}' }
}, {
  tableName: 'accounts',
  instanceMethods: {
    setCredentials: function(obj) {
      this.credentials = JSON.stringify(obj);
    },

    extendCredentials: function(obj) {
      var creds = this.getCredentials();
      extend(creds, obj);
      this.credentials = JSON.stringify(creds);
    },

    getCredentials: function(obj) {
      return JSON.parse(this.credentials) || {};
    }
  }
});

module.exports = Account;
