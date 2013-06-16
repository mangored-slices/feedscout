Q = require 'q'
app = require '../..'
Account = require '../../lib/models/account'
FeedManager = require '../../lib/feed_manager'
{run, local} = require '../../lib/express-decorators'

# ----

app.get "/feed.json", run (req, res, next) ->

  Account.findAll()

  .then (@accounts) =>
    @feed = new FeedManager(accounts)
    @feed.fetch()

  .then (@data) =>
    res.json @data

  .then null, next
