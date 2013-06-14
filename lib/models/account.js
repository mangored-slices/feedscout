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

    /**
     * Returns a credentials hash.
     */
    getCredentials: function(obj) {
      return JSON.parse(this.credentials) || {};
    },

    /**
     * Returns a feed object.
     */
    feed: function() {
      return new TwitterFeed(this);
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

function TwitterFetcher(account) {
  var user = account.getCredentials();

  var credentials = {
    consumer_key: user.consumerKey,
    consumer_secret: user.consumerSecret,
    access_token_key: user.accessToken,
    access_token_secret: user.accessTokenSecret
  };

  // Common
  this.account = account;
  this.username = user.username;
  this.type = "twitter";

  // Twitter-specific
  this.credentials = credentials;
  this.client = new Twitter(credentials);
}

TwitterFetcher.prototype.fetch = function(fn) {
  var user = this.username;

  app.log.debug("[Twitter] requesting");
  this.client.get(
    '/statuses/user_timeline.json',
    { screen_name: user },
    function(data) {
      app.log.debug("[Twitter] received response");
      if (data.constructor === Error) return fn(data);

      var tweets = data.map(function(tweet) {
        return {
          date: +moment(tweet.created_at).toDate(),
          url: 'https://twitter.com/' + user + '/status/' + tweet.id_str,
          text: tweet.text,
          fulltext: null
        };
      });
      console.log(tweets);
      fn(null, tweets);
    });
};

module.exports = Account;
