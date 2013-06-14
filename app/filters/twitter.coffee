TwitterStrategy = require("passport-twitter").Strategy
passport = require("passport")

module.exports =

  ###
  # Endpoint for Twitter OAuth.
  ###

  auth: (req, res, next) ->
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

  callback: (req, res, next) ->
    id = req.params.id
    passport.authenticate("twitter",
      successRedirect: "/admin/accounts/" + id
      failureRedirect: "/admin/accounts/" + id
    ).apply this, arguments
