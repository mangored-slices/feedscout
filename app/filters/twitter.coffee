Strategy = require("passport-twitter").Strategy
passport = require("passport")

module.exports =

  ###
  # Endpoint for Twitter OAuth.
  ###

  auth: (req, res, next) ->
    account = res.locals.account
    id = res.locals.account.id

    # Dynamically set the strategy.
    passport.use new Strategy(
      consumerKey: account.getCredentials().consumerKey
      consumerSecret: account.getCredentials().consumerSecret
      callbackURL: "http://#{req.headers.host}/auth/twitter/callback"
    , (token, tokenSecret, profile, done) ->
      account.extendCredentials
        accessToken: token
        accessTokenSecret: tokenSecret
        username: profile.username
        userId: null
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
    passport.authenticate("twitter",
      successRedirect: "/admin/accounts"
      failureRedirect: "/admin/accounts"
    ).apply this, arguments
