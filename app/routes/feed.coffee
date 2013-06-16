Q = require 'q'
app = require '../..'
_ = require 'underscore'
Entry = require '../../lib/models/entry'
Account = require '../../lib/models/account'
FeedManager = require '../../lib/feed_manager'
{run, local} = require '../../lib/express-decorators'

# ----

app.get "/feed.json", run (req, res, next) ->
  doFetch = !! req.query.refresh

  Account.findAll()

  .then (@accounts) =>
    @feed = new FeedManager(accounts)
    @feed.fetch()  if doFetch

  .then =>
    @feed.get()

  .then (@entries) =>
    Entry.toFeedJSON(@entries)
    
  .then (jsonData) =>

    res.json jsonData

  .then null, next
