Twitter = require("../filters/twitter")
AdminAuth = require("../../lib/admin_auth")
Account = require("../../lib/models/account")
{redirect, local} = require('../../lib/express-decorators')
app = require("../..")

# ----------------------------------------------------------------------------
run = ->
  app.all "/admin*",
    AdminAuth.authenticate

  app.get "/admin",
    redirect("/admin/accounts")

  app.get "/admin/accounts",
    Admin.getAccounts,
    Admin.index

  app.get "/admin/accounts/new/twitter",
    Admin.newTwitter

  app.get "/admin/accounts/new/flickr",
    Admin.newFlickr

  app.get "/admin/accounts/new/instagram",
    Admin.newInstagram

  app.get "/admin/accounts/new/tumblr",
    Admin.newTumblr

  app.get '/admin/accounts/backup',
    Admin.getAccounts,
    Admin.showBackup

  app.get "/admin/accounts/:id",
    Admin.getAccount,
    Admin.show

  app.post "/admin/accounts",
    Admin.create

  app.del "/admin/accounts/:id",
    Admin.getAccount,
    Admin.destroy

  app.get "/admin/accounts/:id/auth/twitter",
    Admin.getAccount,
    Admin.ensureAccountIs("twitter"),
    Twitter.auth

  app.get "/admin/accounts/:id/auth/twitter/callback",
    Admin.getAccount,
    Admin.ensureAccountIs("twitter"),
    Twitter.callback

# ----------------------------------------------------------------------------
Admin =
  ###
  # GET /admin/accounts
  ###
  index: (req, res) ->
    res.render "accounts/index"

  ###
  # GET /admin/accounts/new/twitter
  ###
  newTwitter: (req, res) ->
    res.locals.account = Account.build(
      service: "twitter"
      name: "twitter"
    )
    res.render "accounts/new-twitter"

  ###
  # GET /admin/accounts/new/flickr
  ###
  newFlickr: (req, res) ->
    res.locals.account = Account.build(
      service: "flickr"
      name: "flickr"
    )
    res.render "accounts/new-flickr"

  ###
  # GET /admin/accounts/new/instagram
  ###
  newInstagram: (req, res) ->
    res.locals.account = Account.build(
      service: "instagram"
      name: "instagram"
    )
    res.render "accounts/new-instagram"

  ###
  # GET /admin/accounts/new/tumblr
  ###
  newTumblr: (req, res) ->
    res.locals.account = Account.build(
      service: "tumblr"
      name: "tumblr"
    )
    res.render "accounts/new-tumblr"

  ###
  # GET /admin/accounts/:id
  ###
  show: (req, res) ->
    account = res.locals.account

    res.render "accounts/show-#{account.service}"

  ###
  # GET /admin/accounts/new
  ###
  create: (req, res) ->
    data = req.body.account

    account = res.locals.account = Account.build(data)
    account.setCredentials data.credentials

    service = account.service

    account.save()
    .success ->
      res.redirect "/admin/accounts/#{account.id}"
    .error ->
      res.render "accounts/new-#{service}"

  ###
  # DELETE /admin/accounts/:id
  ###
  destroy: (req, res, next) ->
    account = res.locals.account

    account.destroy().success(->
      res.redirect "/admin/accounts"
    ).error (err) ->
      next err

  ###
  # GET /admin/accounts/backup
  ####
  showBackup: (req, res, next) ->
    data = {
      accounts: res.locals.accounts.map (a) -> a.toBackupJSON()
    }

    res.json data

  # ----------------------------------------------------------------------------
  # Filters

  ###
  # Retrieves an account for editing.
  ###
  getAccount: local 'account', (req, res) ->
    Account.find(req.params.id)

  ###
  # Retrieves the list of accounts for indexing
  ###
  getAccounts: local 'accounts', (req, res) ->
    Account.findAll()

  ###
  # (Filter) ensures the account is of a given service.
  # Useful for OAuth callbacks.
  ###
  ensureAccountIs: (service) ->
    (req, res, next) ->
      account = res.locals.account

      if account.service isnt service
        return next(new Error("Wrong service (#{account.service} is not #{service})"))

      next()

run()
