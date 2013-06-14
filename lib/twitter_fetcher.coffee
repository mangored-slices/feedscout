Twitter = require('twitter')
Moment = require('moment')

###
# Fetcher for Twitter.
# Used by the account model.
###

module.exports = class TwitterFetcher

  constructor: (account) ->
    user = account.getCredentials()

    credentials =
      consumer_key: user.consumerKey
      consumer_secret: user.consumerSecret
      access_token_key: user.accessToken
      access_token_secret: user.accessTokenSecret

    # General
    @account = account
    @username = user.username
    @type = "twitter"

    # Twitter-specific
    @credentials = credentials
    @twitter = new Twitter(credentials)

  ###
  # Fetches items. Returns an array of JSON objects per tweet
  ###

  fetch: (fn) ->
    user = @username

    @twitter.get \
      "/statuses/user_timeline.json",
      { screen_name: user },
      (data) ->
        return fn(data)  if data.constructor is Error

        tweets = data.map (tweet) ->
          date:     +Moment(tweet.created_at).toDate()
          url:      "https://twitter.com/#{user}/status/#{tweet.id_str}"
          text:     tweet.text
          fulltext: null

        fn null, tweets
