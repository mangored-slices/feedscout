Moment = require('moment')
Q = require('q')
_ = require('underscore')
Request = require('superagent')

###
# Fetcher for Tumblr.
# Used by the account model.
###

module.exports = class TumblrFetcher

  constructor: (account) ->
    creds = account.getCredentials()
    @account = account
    @accessToken = creds?.accessToken
    @userId = creds?.userId
    @blogId = creds?.tumblr_blogId

  ###
  # Fetches items. Returns an array of JSON objects per item
  ###
  fetch: ->
    @get("/v2/blog/#{@blogId}/posts/text")

    # Get images
    .then (res) =>
      entries = res
      console.log entries
      []

  ###
  # Performs a GET request.
  #
  #     @get('/v2/blog/').then ->
  ###
  get: (path, options={}) ->
    options.api_key ?= @accessToken
    qs = require('querystring').stringify(options)
    url = "https://api.tumblr.com#{path}?#{qs}"

    Q.promise (ok, fail) =>
      Request
        .get(url)
        .set('Accept', 'application/json')
        .end (err, data) =>
          return fail(err) if err
          ok(data)
