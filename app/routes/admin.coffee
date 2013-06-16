Twitter = require("../filters/twitter")
AdminFilters   = require("../filters/admin")
Account = require("../../lib/models/account")
E = require('../../lib/e')
app = require("../..")


Admin =
  # ----------------------------------------------------------------------------
  # Actions

  index: (req, res) ->
    res.render "accounts/index"

  newTwitter: (req, res) ->
    res.locals.account = Account.build(
      service: "twitter"
      name: "twitter"
    )
    res.render "accounts/new-twitter"

  show: (req, res) ->
    account = res.locals.account

    res.render "accounts/show-#{account.service}"

  create: (req, res) ->
    data = req.body.account

    account = res.locals.account = Account.build(data)
    account.setCredentials data.credentials

    service = account.service

    account.save()
      .success (->
        res.redirect "/admin/accounts/#{account.id}"
      ).error ->
        res.render "accounts/new-#{service}"

  destroy: (req, res, next) ->
    account = res.locals.account

    account.destroy().success(->
      res.redirect "/admin/accounts"
    ).error (err) ->
      next err

  # ----------------------------------------------------------------------------
  # Filters

  ###
  # Retrieves an account for editing.
  # Sets `locals.account`
  ###

  getAccount: (req, res, next) ->
    id = req.params.id

    Account.find(id)
      .error((e) -> next e)
      .success (account) ->
        return next(404)  unless account

        res.locals.account = account
        next()

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

  ###
  # Retrieves the list of accounts for indexing
  # Sets `locals.accounts`
  ###

  getAccounts: (req, res, next) ->
    Account.findAll()
      .error((e) -> next e)
      .success (accounts) ->
        res.locals.accounts = accounts
        next()


# ----------------------------------------------------------------------------

app.all "/admin*",
  AdminFilters.authenticate

app.get "/admin",
  E.redirect("/admin/accounts")

app.get "/admin/accounts",
  Admin.getAccounts,
  Admin.index

app.get "/admin/accounts/new/twitter",
  Admin.newTwitter

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
