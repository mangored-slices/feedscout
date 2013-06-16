Account = require('../../lib/models/account')
Q = require('q')
app = require('../..')
{run, local} = require('../../lib/express-decorators')

# ----------------------------------------------------------------------------
# Sources controller

Sources =
  get: local 'accounts', ->
    Account.findAll()

  show: run (req, res) ->
    res.json sources: @accounts

# ----------------------------------------------------------------------------
# Feed controller

Feed =
  fetch: (name) ->
    Q.when(
      Account.find(where: { name: name })

    ).then (twitter) ->
      twitter.fetcher().fetch()

  show: (req, res, next) ->
    Q.all([
      Feed.fetch('twitter')
    ])
    .spread (feeds) ->
      res.json feeds

    .fail(next)

# ----------------------------------------------------------------------------
app.get "/feed.json",
  Feed.show

app.get "/sources.json",
  Sources.get,
  Sources.show
