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

function TwitterFeed(account) {
  var Twitter = require('twitter');
  var creds = account.getCredentials();

  this.account = account;
  this.twitter = new Twitter({
    consumer_key: creds.consumerKey,
    consumer_secret: creds.consumerSecret,
    access_token_key: creds.accessTokenKey,
    access_token_secret: creds.accessTokenSecret
  });
}

TwitterFeed.prototype.fetch = function() {
  this.twitter.getHomeTimeline({}, function(data) {
    console.log(data);
  });
};

module.exports = Account;
