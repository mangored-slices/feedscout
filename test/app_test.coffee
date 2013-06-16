Setup = require("./setup")

describe "App", ->

  before Setup.loadApp
  beforeEach Setup.sync

  it "Homepage should work", (done) ->
    request(app)
      .get("/")
      .expect 200, done

  it "should have the right env", ->
    app.get("env").should.equal "test"
