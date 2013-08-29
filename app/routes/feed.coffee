Q = require 'q'
app = require '../..'
_ = require 'underscore'
Cors = require '../../lib/cors'
Entry = require '../../lib/models/entry'
Account = require '../../lib/models/account'
FeedManager = require '../../lib/feed_manager'
{run, local} = require '../../lib/express-decorators'

# ----

app.get "/feed.json",
  Cors,
  run (req, res, next) ->
    doFetch = !! req.query.refresh

    Account.findAll()

    .then (@accounts) =>
      @feed = new FeedManager(accounts)
      doFetch ||= @feed.age() > 3600000

      if doFetch
        app.log.info "Refreshing feed"
        @feed.fetch()

    .then =>
      @feed.get()

    .then (@entries) =>
      Entry.toFeedJSON(@entries)
      
    .then (jsonData) =>

      res.json jsonData

    .then null, next
