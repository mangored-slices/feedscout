Setup = require './setup'
Account = require '../lib/models/account'
TwitterFetcher = require '../lib/twitter_fetcher'
Moment = require 'moment'
_ = require 'underscore'

describe 'Twitter Fetcher', ->

  beforeEach Setup.sync

  describe 'fetch()', ->

    # Fetch data.
    beforeEach pt ->
      @twitter.fetcher().fetch()
      .then (@data) =>

    it 'should have valid data', ->
      assert.lengthOf @data, 10

      tweet = @data[2]
      assert.equal tweet.url, 'https://twitter.com/john/status/2002'
      assert.equal tweet.text, 'Hello world 2'
      assert.equal tweet.date, +Moment('2013-01-01')
      assert.equal tweet.fullText, null

    it 'should have called .get properly', ->
      get = TwitterFetcher::get

      assert.isTrue get.calledOnce
      assert.equal get.firstCall.args[0], '/statuses/user_timeline.json'
      assert.equal json(get.firstCall.args[1]), json({ screen_name: 'john' })

  # ----

  # @twitter
  beforeEach pt ->
    Account.build
      service: "twitter"
      name: "mytwitter"
    .setCredentials
      username: 'john'
    .save()
    .then (@twitter) =>

  # Mock the Twitter API.
  beforeEach ->
    sinon.stub TwitterFetcher::, 'get', (url, data, callback) ->
      data = _(10).times (i) ->
        created_at: '2013-01-01'
        id_str: "#{2000 + i}"
        text: "Hello world #{i}"

      callback data

  afterEach ->
    TwitterFetcher::get.restore()
