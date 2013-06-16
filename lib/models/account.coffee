app     = require("../..")
Sq      = require("sequelize")
extend  = require("util")._extend
Twitter = require("twitter")
_       = require("underscore")
Moment  = require("moment")

###
# An account.
#
#     creds = account.getCredentials();
#
#     // Twitter:
#     creds.username
#     creds.consumerKey
#     creds.consumerSecret
#     creds.accessToken
#     creds.accessTokenSecret
#
#     // Fetcher
#     fetcher = account.fetcher();
#     fetcher.fetch(function(err, data) {
#       ...
#     });
###

Account = module.exports = app.sequelize().define "Account",

  # Attributes
  name: Sq.STRING
  service: Sq.STRING
  credentials: {type: Sq.TEXT, defaultValue: "{}"}
  lastUpdated: Sq.DATE

,
  tableName: "accounts"

  instanceMethods:

    ###
    # Sets credentials JSON.
    ###
    setCredentials: (obj) ->
      @credentials = JSON.stringify(obj)
      this

    ###
    # Adds more stuff to credentials.
    ###
    extendCredentials: (obj) ->
      creds = @getCredentials()
      extend creds, obj
      @credentials = JSON.stringify(creds)
      this

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
        name: @name
        service: @service
        lastUpdated: Moment(@lastUpdated)?.format()

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
    # Returns time since last updated in miliseconds
    ###
    age: ->
      +new Date() - @lastUpdated

    ###
    # These are consumed by toJSON()
    ###
    twitter:
      toJSON: ->
        creds = @getCredentials()
        username: creds.username
        displayName: creds.displayName
        photo: creds.photo

Entry = require('./entry')
