Moment = require('moment')
Q = require('q')
_ = require('underscore')
Request = require('superagent')

unhtml = (str) -> str.replace /<.*?>/g, ''

###
# Fetcher for Tumblr.
# Used by the account model.
###

module.exports = class TumblrFetcher

  constructor: (account) ->
    creds = account.getCredentials()
    @account = account
    @apiKey = creds?.consumerKey
    @userId = creds?.userId
    @blogId = creds?.tumblr_blogId

  ###
  # Fetches items. Returns an array of JSON objects per item
  ###
  fetch: ->
    @get("/v2/blog/#{@blogId}/posts/")

    # Get images
    .then (res) =>
      entries = res.body?.response?.posts
      throw new Error('Wrong format') unless entries?

      entries = _(entries).select (e) ->
        (e?.state is 'published') and (_(['quote', 'text', 'photo']).include(e.type))

    .then (entries) =>
      entries.map (e) =>
        entry =
          accountId: @account.id
          date:      Date(e.timestamp*1000)
          url:       e.post_url
          data:      e

        if e.type is 'photo'
          entry.text     = unhtml(e.caption)
          entry.fulltext = null

        else if e.type is 'quote'
          entry.text     = e.text
          entry.fulltext = null

        else
          entry.text     = e.title
          entry.fulltext = e.body

        entry

  ###
  # Performs a GET request.
  #
  #     @get('/v2/blog/ID/posts/').then ->
  ###
  get: (path, options={}) ->
    options.api_key ?= @apiKey
    qs = require('querystring').stringify(options)
    url = "https://api.tumblr.com#{path}?#{qs}"

    Q.promise (ok, fail) =>
      Request
        .get(url)
        .set('Accept', 'application/json')
        .end (err, data) =>
          return fail(err) if err
          ok(data)
