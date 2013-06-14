Twitter = require("../filters/twitter")
Admin   = require("../filters/admin")
Account = require("../../lib/models/account")

app = require("../..")

# ----------------------------------------------------------------------------
# Actions

index = (req, res) ->
  res.render "accounts/index"

###
# GET /admin/accounts
###

newTwitter = (req, res) ->
  res.locals.account = Account.build(
    service: "twitter"
    name: "twitter"
  )
  res.render "accounts/new-twitter"

###
# GET /admin/accounts/:id
###

show = (req, res) ->
  account = res.locals.account
  res.render "accounts/show-" + account.service

###
# POST /admin/accounts
# input is body.account
###

create = (req, res) ->
  data = req.body.account

  account = res.locals.account = Account.build(data)
  account.setCredentials data.credentials

  service = account.service

  account.save()
    .success (->
      res.redirect "/admin/accounts/" + account.id
    ).error ->
      res.render "accounts/new-" + service

###
# DELETE /admin/accounts/:id
###

destroy = (req, res, next) ->
  account = res.locals.account

  account.destroy().success(->
    res.redirect "/admin/accounts"
  ).error (err) ->
    next err

# ----------------------------------------------------------------------------
# Filters

###
# Retrieves an account for editing.
###

getAccount = (req, res, next) ->
  id = req.params.id

  Account.find(id)
    .error((e) -> next e)
    .success (account) ->
      res.locals.account = account
      next()

###
# (Filter) ensures the account is of a given service.
# Useful for OAuth callbacks.
###

ensureAccountIs = (service) ->
  (req, res, next) ->
    account = res.locals.account

    if account.service isnt service
      return next(new Error("Wrong service (#{account.service} is not #{service})"))

    next()

###
# Retrieves the list of accounts for indexing
###

getAccounts = (req, res, next) ->
  Account.findAll()
    .error((e) -> next e)
    .success (accounts) ->
      res.locals.accounts = accounts
      next()

###
# Redirect helper
###

redirect = (url) ->
  (req, res) -> res.redirect url

# ----------------------------------------------------------------------------

app.all "/admin*",
  Admin.authenticate

app.get "/admin",
  redirect("/admin/accounts")

app.get "/admin/accounts",
  getAccounts, index

app.get "/admin/accounts/new/twitter",
  newTwitter

app.get "/admin/accounts/:id",
  getAccount, show

app.post "/admin/accounts",
  create

app.del "/admin/accounts/:id",
  getAccount, destroy

app.get "/admin/accounts/:id/auth/twitter",
  getAccount, ensureAccountIs("twitter"), Twitter.auth

app.get "/admin/accounts/:id/auth/twitter/callback",
  getAccount, ensureAccountIs("twitter"), Twitter.callback
