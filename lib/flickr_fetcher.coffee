Moment = require('moment')
Q = require('q')
_ = require('underscore')
OAuth = require('oauth')
Flickr = require('flickr').Flickr

indexBy = (list, field) ->
  object = {}
  list.forEach (item) ->
    object[item[field]] = item
  object

###
# Fetcher for Flickr.
# Used by the account model.
###

module.exports = class FlickrFetcher

  constructor: (account) ->
    creds = account.getCredentials()
    @account = account
    # @flickr = new FlickrApi(creds)
    @flickr = new Flickr(creds.consumerKey, creds.consumerSecret, {
      oauth_token: creds.accessToken
      oauth_token_secret: creds.accessTokenSecret
    })

  ###
  # Fetches items. Returns an array of JSON objects per item
  ###
  fetch: ->
    @get('flickr.people.getPhotos',
      user_id: 'me'
      privacy_filter: 1 # public
      extras: ['url_m', 'url_l', 'description', 'date_upload', 'url_o']
    )

    # Extract the list of photos
    .then (data) =>
      list = data?.photos?.photo
      throw new Error("Unexpected format") unless list

      list

    # Fetch sizes for each photo
    .then (photos) =>
      photos.map (photo) =>
        accountId: @account.id
        text: photo.title
        date: new Date(parseInt(photo.dateupload, 10)*1000)
        url: null
        fulltext: photo.description?._content
        image: photo.url_m
        imageLarge: photo.url_l
        data: JSON.stringify(photo)

  ###
  # Fetch from Flickr via Oauth. Returns a promise.
  ###
  get: (method, options={}) ->
    Q.promise (ok, fail) =>
      @flickr.executeAPIRequest method, options, true, (err, data) ->
        if err then fail(err) else ok(data)
