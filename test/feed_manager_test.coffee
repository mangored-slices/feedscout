_ = require 'underscore'
Setup = require './setup'
Moment = require 'moment'
Account = require '../lib/models/account'
Entry = require '../lib/models/entry'
FeedManager = require '../lib/feed_manager'
TwitterFetcher = require '../lib/twitter_fetcher'

describe 'FeedManager', ->

  beforeEach Setup.sync

  describe '.fetch() (stubbed .sync())', ->
    beforeEach ->
      sinon.stub FeedManager::, 'sync', (account, entries) ->
        Q.promise (ok) -> ok()

    afterEach ->
      FeedManager::sync.restore()

    beforeEach pt ->
      @manager = new FeedManager([ @twitter1, @twitter2 ])
      @manager.fetch()

    it 'should call sync() for each account', ->
      assert.equal @manager.sync.callCount, 2

    it 'should call the correct accounts', ->
      sync = @manager.sync

      assert.equal sync.firstCall.args[0].id, @twitter1.id
      assert.equal sync.secondCall.args[0].id, @twitter2.id

    it 'should call with the entries', ->
      args = @manager.sync.firstCall.args
      entries = args[1]

      assert.lengthOf entries, 3
      assert.match entries[0].text, /^Hello world 1/
      assert.match entries[1].text, /^Hello world 2/

  # ----

  describe 'first time syncing', ->
    beforeEach pt ->
      @manager = new FeedManager([ @twitter1, @twitter2 ])
      @manager.fetch()

    it 'Entries should exist', pt ->
      Entry.findAll()
      .then (entries) ->
        assert.lengthOf entries, 6

  it '.updated_at', ->
    @manager = new FeedManager([ @twitter1, @twitter2 ])
    assert.equal +@manager.updated_at(), +Moment('05/04/2010')

  describe '/feed.json', ->
    before Setup.loadApp

    beforeEach (done) ->
      request(app)
        .get('/feed.json')
        .expect 200, (err, data) =>
          # TODO

  # ----

  beforeEach pt ->
    Account.build(service: "twitter", name: "mytwitter", updated_at: Moment('05/04/2010').toDate())
    .setCredentials(username: 'ryu')
    .save()
    .then (@twitter1) =>

  beforeEach pt ->
    Account.build(service: "twitter", name: "myothertwitter", updated_at: Moment('05/08/2010').toDate())
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

