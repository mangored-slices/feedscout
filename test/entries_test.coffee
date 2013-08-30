Setup = require "./setup"
Account = require("../lib/models/account")
Entry = require("../lib/models/entry")
_ = require("underscore")

describe "Entries", ->
  beforeEach Setup.sync

  it "Feed", pt ->
    Entry.findAll()
    .then (entry) => entry[0].getAccount()
    .then (account) =>
      assert.equal @twitter.id, account.id

  beforeEach pt ->
    Account.build
      service: "twitter"
      name: "mytwitter"
    .save()
    .then (@twitter) =>

  beforeEach pt ->
    Account.build
      service: "instagram"
      name: "myinstagram"
    .save()
    .then (@instagram) =>

  beforeEach pt ->
    Q.all _(30).times (n) =>
      Entry.build
        text: "hello #{n}"
        account_id: @twitter.id
      .save()
