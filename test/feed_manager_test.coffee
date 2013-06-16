_ = require 'underscore'
Setup = require './setup'
Moment = require 'moment'
Account = require '../lib/models/account'
FeedManager = require '../lib/feed_manager'
TwitterFetcher = require '../lib/twitter_fetcher'

describe 'FeedManager', ->

  beforeEach Setup.sync

  describe 'Feed', ->
    beforeEach pt ->
      @manager = new FeedManager([ @twitter1, @twitter2 ])
      @manager.fetch()
      .then (@data) =>

    it 'should right number of values', ->
      assert.lengthOf @data, 6

    it 'should right urls', ->
      urls = _(@data).pluck('url')
      assert.equal json(urls), json([
        'https://twitter.com/ken/status/2006'
        'https://twitter.com/ken/status/2005'
        'https://twitter.com/ken/status/2004'
        'https://twitter.com/ryu/status/2003'
        'https://twitter.com/ryu/status/2002'
        'https://twitter.com/ryu/status/2001'
      ])

  describe '/feed.json', ->
    before Setup.loadApp

    beforeEach (done) ->
      request(app)
        .get('/feed.json')
        .expect 200, (err, data) =>
          @data = JSON.parse(data.text)
          done()

    it 'should right number of values', ->
      assert.lengthOf @data.entries, 6

    it 'range correct order', ->
      range = @data.range
      assert.isTrue Moment(range.from) < Moment(range.to)

    it 'correct range', ->
      range = @data.range
      assert.equal _(@data.entries).first().date, range.to
      assert.equal _(@data.entries).last().date, range.from

    it 'should right urls', ->
      urls = _(@data.entries).pluck('url')
      assert.equal json(urls), json([
        'https://twitter.com/ken/status/2006'
        'https://twitter.com/ken/status/2005'
        'https://twitter.com/ken/status/2004'
        'https://twitter.com/ryu/status/2003'
        'https://twitter.com/ryu/status/2002'
        'https://twitter.com/ryu/status/2001'
      ])


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
