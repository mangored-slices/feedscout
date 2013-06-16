Setup = require "./setup"
Account = require("../lib/models/account")

describe "Accounts", ->
  before Setup.loadApp
  beforeEach Setup.sync

  it "/sources.json", (done) ->
    request(app)
      .get("/sources.json")
      .expect 200, (err, data) ->
        result = data.res.body
        assert.equal 2, result.sources.length
        assert.equal "mytwitter", result.sources[0].name
        assert.equal "twitter",   result.sources[0].service
        assert.equal "rstacruz",  result.sources[0].username
        assert.equal "instagram", result.sources[1].service
        done()

  beforeEach pt ->
    Account.build
      service: "twitter"
      name: "mytwitter"
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

