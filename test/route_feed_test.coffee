_ = require 'underscore'
Setup = require './setup'
Account = require '../lib/models/account'
FeedManager = require '../lib/feed_manager'
TwitterFetcher = require '../lib/twitter_fetcher'

return

describe '/feeds.json', ->

  before Setup.loadApp
  beforeEach Setup.sync

  describe 'with things', (done) ->
    request(app)
      .get('/feed.json')
      .expect 200, (err, data) =>
        done()

  # ----

  beforeEach pt ->
    Account.build(service: "twitter", name: "mytwitter")
    .setCredentials(username: 'ryu')
    .save()
    .then (@twitter1) =>

  beforeEach pt ->
    Account.build(service: "twitter", name: "myothertwitter")
    .setCredentials(username: 'ken')
    .save()
    .then (@twitter2) =>

  # Mock the Twitter API.
  beforeEach ->
    n = 0
    sinon.stub TwitterFetcher::, 'get', (url, data, callback) ->
      data = _(3).times ->
        n += 1
        date = "2013-01-#{n}"
        created_at: date
        id_str: "#{2000 + n}"
        text: "Hello world #{n} at #{date}"

      callback data

  afterEach ->
    TwitterFetcher::get.restore()
