Setup = require "./setup"
Account = require("../lib/models/account")
Moment = require 'moment'

describe "Accounts", ->

  before Setup.loadApp
  beforeEach Setup.sync

  it "/sources.json", (done) ->
    request(app)
      .get("/sources.json")
      .expect 200, (err, data) ->
        result = data.res.body

        assert.equal 2, result.sources.length

        assert.equal result.sources[0].name, "mytwitter"
        assert.equal result.sources[0].service, "twitter"
        assert.equal result.sources[0].lastUpdated, Moment('05/05/2013').format()
        assert.equal result.sources[0].username, "rstacruz"

        assert.equal result.sources[1].service, "instagram"
        done()

  beforeEach pt ->
    Account.build
      service: "twitter"
      name: "mytwitter"
      lastUpdated: Moment('05/05/2013').toDate()
    .setCredentials
      username: "rstacruz"
      displayName: "Rico Sta. Cruz"
      photoUrl: "http://imgur.com/a.jpg"
    .save()

  beforeEach pt ->
    Account.build
      service: "instagram"
      name: "myinstagram"
    .setCredentials
      username: "ricostacruz"
      displayName: "Rico Sta. Cruz"
      photoUrl: "http://imgur.com/b.jpg"
    .save()

