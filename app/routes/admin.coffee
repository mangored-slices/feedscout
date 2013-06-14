express = require("express")
passport = require("passport")
TwitterStrategy = require("passport-twitter").Strategy
Account = require("../../lib/models/account")
admin = require("./admin_filters")
wrap = require("../../lib/utils").wrap
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
# Twitter OAuth

###
# Endpoint for Twitter OAuth.
###

passportTwitter = (req, res, next) ->
  account = res.locals.account
  id = res.locals.account.id

  # Dynamically set the strategy.
  passport.use new TwitterStrategy(
    consumerKey: account.getCredentials().consumerKey
    consumerSecret: account.getCredentials().consumerSecret
    callbackURL: "http://127.0.0.1:4567/admin/accounts/#{id}/auth/twitter/callback"
  , (token, tokenSecret, profile, done) ->
    account.extendCredentials
      accessToken: token
      accessTokenSecret: tokenSecret
      username: profile.username
      displayName: profile.displayName
      photo: profile.photos[0].value

    account.save().success(->
      done()
    ).error (e) ->
      done e
  )

  passport.authenticate("twitter").apply this, arguments

###
# Callback for twitter auth.
# Does nothing, really... since it's the Strategy that handles things.
###

passportTwitterCallback = (req, res, next) ->
  id = req.params.id
  passport.authenticate("twitter",
    successRedirect: "/admin/accounts/" + id
    failureRedirect: "/admin/accounts/" + id
  ).apply this, arguments

# ----------------------------------------------------------------------------

app.all "/admin*",
  admin.authenticate

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
  getAccount, ensureAccountIs("twitter"), passportTwitter

app.get "/admin/accounts/:id/auth/twitter/callback",
  getAccount, ensureAccountIs("twitter"), passportTwitterCallback
