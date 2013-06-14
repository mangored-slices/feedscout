Account = require("../../lib/models/account")
app = require("../..")

# ----------------------------------------------------------------------------

sources = (req, res) ->
  accounts = res.locals.accounts

  res.json sources: accounts

###
# Fetches available accounts.
# Sets `locals.accounts`
###

getAccounts = (req, res, next) ->
  Account.findAll()
    .error((e) -> next e)
    .success (accounts) ->
      res.locals.accounts = accounts
      next()

###
# Lol ionno
###

getTwitter = (req, res, next) ->
  Account.find(where: { name: "twitter" })
    .error((e) -> next e)
    .success (account) ->

      account.fetcher().fetch (err, data) ->
        return next(err)  if err
        res.json data

# ----------------------------------------------------------------------------

app.get "/feed.json",
  getAccounts,
  getTwitter

app.get "/sources.json",
  getAccounts,
  sources
