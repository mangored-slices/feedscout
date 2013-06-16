Setup = require "./setup"
Account = require("../lib/models/account")
Entry = require("../lib/models/entry")

describe "Entries", ->
  beforeEach Setup.sync

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

  beforeEach pt ->
    Account.findAll()
    .then (@accounts) =>

  beforeEach pt ->
    Entry.build(text: 'hello', accountId: @accounts[0].id).save()

  it "Feed", pt ->
    Entry.findAll()
    .then((entry) -> entry[0].getAccount())
    .then (account) ->
      assert.equal json(@accounts[0]), json(account)
