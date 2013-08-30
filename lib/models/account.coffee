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
  updated_at: Sq.DATE

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
      creds = @getCredentials()
      obj =
        name: @name
        service: @service
        updated_at: Moment(@updated_at)?.format()
        username: creds?.username
        displayName: creds?.displayName
        photo: creds?.photo

    isAuthorized: ->
      @getCredentials()?.accessToken

    ###
    # return Feed fetcher
    ###
    fetcher: ->
      switch @service
        when 'twitter' then new (require '../twitter_fetcher')(this)
        when 'flickr' then new (require '../flickr_fetcher')(this)
        when 'instagram' then new (require '../instagram_fetcher')(this)
        when 'tumblr' then new (require '../tumblr_fetcher')(this)

    ###
    # Returns time since last updated in miliseconds
    ###
    age: ->
      +new Date() - @updated_at

    ###
    # For backup purposes
    ###
    toBackupJSON: ->
      name: @name
      service: @service
      credentials: @getCredentials()
      updated_at: Moment(@updated_at)?.format()

    username: ->
      @getCredentials()?.username ||
      @getCredentials()?.userId


    avatar: ->
      @getCredentials()?.photo

Entry = require('./entry')
