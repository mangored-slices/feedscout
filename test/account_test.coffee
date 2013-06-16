Setup = require "./setup"
Account = require("../lib/models/account")

describe "Accounts", ->
  beforeEach Setup.sync

  beforeEach pt ->
    console.log 'twitter'
    Account.build
      service: "twitter"
      name: "mytwitter"
    .setCredentials
      username: "rstacruz"
      displayName: "Rico Sta. Cruz"
      photoUrl: "http://imgur.com/a.jpg"
    .save()

  beforeEach pt ->
    console.log 'instagram'
    Account.build
      service: "instagram"
      name: "myinstagram"
    .setCredentials
      username: "ricostacruz"
      displayName: "Rico Sta. Cruz"
      photoUrl: "http://imgur.com/b.jpg"
    .save()

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
