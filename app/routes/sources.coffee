Account = require('../../lib/models/account')
Q = require('q')
app = require('../..')
{run, local} = require('../../lib/express-decorators')

# ----------------------------------------------------------------------------
# Sources controller

app.get "/sources.json", (req, res, next) ->

  Q.when(Account.findAll())

  .then (accounts) ->
    res.json sources: accounts

  .fail(next)
