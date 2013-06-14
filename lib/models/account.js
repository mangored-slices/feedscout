var app = require('../..');
var Sq = require('sequelize');
var extend = require('util')._extend;
var Twitter = require('twitter');
var _ = require('underscore');
var moment = require('moment');

/**
 * An account.
 *
 *     creds = account.getCredentials();
 *
 *     // Twitter:
 *     creds.username
 *     creds.consumerKey
 *     creds.consumerSecret
 *     creds.accessToken
 *     creds.accessTokenSecret
 *
 *     // Fetcher
 *     fetcher = account.fetcher();
 *     fetcher.fetch(function(err, data) {
 *       ...
 *     });
 */

var Account = module.exports = app.sequelize().define('Account', {
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

    /**
     * Returns a credentials hash.
     */
    getCredentials: function(obj) {
      return JSON.parse(this.credentials) || {};
    },

    /**
     * Returns a JSON representation.
     */
    toJSON: function() {
      var obj = { id: this.id, name: this.name, service: this.service };

      var service = this.service;
      if (this[service]) extend(obj, this[service].toJSON.apply(this));

      return obj;
    },

    /**
     * Returns Twitter API client
     */

    fetcher: function() {
      var TwitterFetcher = require('../twitter_fetcher');
      return new TwitterFetcher(this);
    },

    /**
     * Return twitter info for jsoning
     */

    twitter: {
      toJSON: function() {
        var creds = this.getCredentials();

        return {
          username: creds.username,
          displayName: creds.displayName,
          photo: creds.photo
        };
      }
    }
  }
});
