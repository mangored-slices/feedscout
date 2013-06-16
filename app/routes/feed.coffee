Q = require 'q'
app = require '../..'
_ = require 'underscore'
Account = require '../../lib/models/account'
FeedManager = require '../../lib/feed_manager'
{run, local} = require '../../lib/express-decorators'

# ----

app.get "/feed.json", run (req, res, next) ->

  Account.findAll()

  .then (@accounts) =>
    @feed = new FeedManager(accounts)
    @feed.fetch()

  .then (@entries) =>
    data = {
      range: {
        from: _(@entries).last().date,
        to: _(@entries).first().date
      }
      entries: @entries
    }

    res.json data

  .then null, next
