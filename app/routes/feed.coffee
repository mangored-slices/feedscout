Account = require('../../lib/models/account')
Q = require('q')
app = require('../..')

# ----------------------------------------------------------------------------

sources = (req, res, next) ->

  Q.when(
    Account.findAll()

  ).then (accounts) ->
    res.json sources: accounts

  .fail(next)

###
# Lol ionno
###

fetchFeed = (name) ->
  Q.when(
    Account.find(where: { name: name })

  ).then (twitter) ->
    twitter.fetcher().fetch()

showFeed = (req, res, next) ->

  Q.all([
    fetchFeed('twitter')
  ])
  .spread (feeds) ->
    res.json feeds

  .fail(next)

# ----------------------------------------------------------------------------

app.get "/feed.json",
  showFeed

app.get "/sources.json",
  sources
