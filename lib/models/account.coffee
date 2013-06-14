app     = require("../..")
Sq      = require("sequelize")
extend  = require("util")._extend
Twitter = require("twitter")
_       = require("underscore")
moment  = require("moment")

###
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
###

Account = module.exports = app.sequelize().define "Account",

  # Attributes
  name: Sq.STRING
  service: Sq.STRING
  credentials: {type: Sq.TEXT, defaultValue: "{}"}

,
  tableName: "accounts"

  instanceMethods:

    ###
    # Sets credentials JSON.
    ###

    setCredentials: (obj) ->
      @credentials = JSON.stringify(obj)

    ###
    # Adds more stuff to credentials.
    ###

    extendCredentials: (obj) ->
      creds = @getCredentials()
      extend creds, obj
      @credentials = JSON.stringify(creds)

    ###
    # Returns credentials as a JSON object.
    ###

    getCredentials: (obj) ->
      JSON.parse(@credentials) or {}

    ###
    # Returns a JSON representation for viewing.
    ###

    toJSON: ->
      obj =
        id: @id
        name: @name
        service: @service

      service = @service
      extend obj, this[service].toJSON.apply(this)  if this[service]
      obj

    ###
    # return Feed fetcher
    ###

    fetcher: ->
      TwitterFetcher = require("../twitter_fetcher")
      new TwitterFetcher(this)

    ###
    # For JSON
    ###
    
    twitter:
      toJSON: ->
        creds = @getCredentials()
        username: creds.username
        displayName: creds.displayName
        photo: creds.photo

