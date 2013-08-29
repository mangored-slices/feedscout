Account = require('../../lib/models/account')
Q = require('q')
app = require('../..')
Cors = require '../../lib/cors'
{run, local} = require('../../lib/express-decorators')

# ----------------------------------------------------------------------------
# Sources controller

app.get "/sources.json",
  Cors,
  (req, res, next) ->

    Q.when(Account.findAll())

    .then (accounts) ->
      res.json sources: accounts

    .fail(next)
