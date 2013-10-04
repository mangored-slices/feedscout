Q = require 'q'
app = require '../..'
_ = require 'underscore'
Cors = require '../../lib/cors'
Entry = require '../../lib/models/entry'
Account = require '../../lib/models/account'
AdminAuth = require '../../lib/admin_auth'
FeedManager = require '../../lib/feed_manager'
{run, local} = require '../../lib/express-decorators'

# ----

Filters =
  authIfRefresh: (req, res, next) ->
    force = !! req.query.refresh
    if force
      AdminAuth.authenticate(req, res, next)
    else
      next()

app.get "/feed.json",
  Cors,
  Filters.authIfRefresh,
  run (req, res, next) ->
    Account.findAll()

    .then (@accounts) =>
      @feed = new FeedManager(accounts)

    .then =>
      @feed.get()

    .then (@entries) =>
      Entry.toFeedJSON(@entries)
      
    .then (jsonData) =>
      res.json jsonData
      null

    .then =>
      force = !! req.query.refresh
      isOld = @feed.age() > 3600000

      if force or isOld
        app.log.info "Refreshing feed"
        @feed.fetch()

    .then null, next
