_ = require 'underscore'
Setup = require './setup'
Moment = require 'moment'
Account = require '../lib/models/account'
Entry = require '../lib/models/entry'
FeedManager = require '../lib/feed_manager'
TwitterFetcher = require '../lib/twitter_fetcher'

describe 'FeedManager', ->

  beforeEach Setup.sync

  it 'should have the right assumptions', pt ->
    Entry.findAll()
    .then (entries) ->
      assert.lengthOf entries, 11
      assert.equal +entries[0].date, +Moment("05/10/2013").toDate()
      assert.equal +entries[10].date, +Moment("05/20/2013").toDate()

  describe '.get', ->
    it '.get()', pt ->
      @manager = new FeedManager([ @twitter, {id: 2} ])
      @manager.get()
      .then (entries) ->
        assert.lengthOf entries, 11
        assert.equal entries[0].text, "Hello, May 20"
        assert.equal entries[10].text, "Hello, May 10"

    it '.get(5)', pt ->
      @manager = new FeedManager([ @twitter, {id: 2} ])
      @manager.get(5)
      .then (entries) ->
        assert.lengthOf entries, 5
        assert.equal entries[0].text, "Hello, May 20"
        assert.equal entries[4].text, "Hello, May 16"

  describe 'replace old tweets (.sync())', ->
    beforeEach pt ->
      @manager = new FeedManager([ @twitter ])
      @manager.fetch()

      .then ->
        Entry.findAll({ order: 'date DESC' })

      .then (@entries) =>

    it 'should have right length', ->
      assert.lengthOf @entries, 13

    it 'should update account last updated info', pt ->
      Account.find(@twitter.id)
      .then (account) ->
        delta = (+new Date() - account.lastUpdated)
        assert.operator delta, '<', 60000

    it 'should have right tweets', ->
      texts = _(@entries).pluck('text')
      assert.equal texts[0], 'Cheers from Twitter, May 22'
      assert.equal texts[4], 'Cheers from Twitter, May 18'
      assert.equal texts[5], 'Hello, May 17'
      assert.equal texts[12], 'Hello, May 10'

  # @twitter = new Account
  beforeEach pt ->
    Account.build(service: "twitter", name: "mytwitter")
    .setCredentials(username: 'ryu')
    .save()
    .then (@twitter) =>

  # Make entries
  beforeEach pt ->
    promises = for n in [10..20]
      Entry.build
        accountId: @twitter.id
        text:      "Hello, May #{n}"
        date:      Moment("05/#{n}/2013").toDate()
      .save()

    Q.all promises

  # Stub Twitter API
  beforeEach ->
    sinon.stub TwitterFetcher::, 'get', (url, data, callback) ->
      data = for n in [18..22]
        created_at: "05/#{n}/2013"
        id_str: "2000#{n}"
        text: "Cheers from Twitter, May #{n}"

      callback data

  afterEach ->
    TwitterFetcher::get.restore()

