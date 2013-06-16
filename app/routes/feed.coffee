Account = require('../../lib/models/account')
Q = require('q')
app = require('../..')
E = require('../../lib/e')

# ----------------------------------------------------------------------------
# Sources controller

Sources =
  get: E.local 'accounts', ->
    Account.findAll()

  show: E.run (req, res) ->
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
  Feed.fetch

app.get "/sources.json",
  Sources.get,
  Sources.show
