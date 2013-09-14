Moment = require('moment')
Q = require('q')
_ = require('underscore')
Request = require('superagent')

###
# Fetcher for Instagram.
# Used by the account model.
###

module.exports = class InstagramFetcher

  constructor: (account) ->
    creds = account.getCredentials()
    @account = account
    @accessToken = creds?.accessToken
    @userId = creds?.userId

  ###
  # Fetches items. Returns an array of JSON objects per item
  ###
  fetch: ->
    @get("/v1/users/#{@userId}/media/recent")

    # Get images
    .then (res) =>
      entries = res.body.data
      entries = _(entries).filter (e) -> e.type is 'image'

    # Map
    .then (entries) =>
      _(entries).map (e) =>
        img =
          height: e.images?.standard_resolution?.height
          width:  e.images?.standard_resolution?.width

        account_id: @account.id
        date:      new Date(parseInt(e.created_time, 10) * 1000)
        url:       e.link
        text:      e.caption?.text
        fulltext:  null
        image:       e.images?.low_resolution?.url
        image_large:  e.images?.standard_resolution?.url
        image_ratio:  (img.width / img.height) || 1.0
        data:      JSON.stringify(e)

  ###
  # Performs a GET request.
  #
  #     @get('/v1/users/USERID/media/recent').then ->
  ###
  get: (path, options={}) ->
    options.access_token ?= @accessToken
    qs = require('querystring').stringify(options)
    url = "https://api.instagram.com#{path}?#{qs}"

    Q.promise (ok, fail) =>
      Request
        .get(url)
        .set('Accept', 'application/json')
        .end (err, data) =>
          return fail(err) if err
          ok(data)
