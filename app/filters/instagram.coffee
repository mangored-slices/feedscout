Strategy = require("passport-instagram").Strategy
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
      clientID: account.getCredentials().clientId
      clientSecret: account.getCredentials().clientSecret
      callbackURL: "http://#{req.headers.host}/auth/instagram/callback"
    , (token, tokenSecret, profile, done) ->
      account.extendCredentials
        accessToken: token
        accessTokenSecret: tokenSecret
        username: profile.username
        displayName: profile.displayName
        photo: profile._json?.data?.profile_picture

      account.save().success(->
        done()
      ).error (e) ->
        done e
    )

    passport.authenticate("instagram").apply this, arguments

  ###
  # Callback for twitter auth.
  # Does nothing, really... since it's the Strategy that handles things.
  ###

  callback: (req, res, next) ->
    passport.authenticate("instagram",
      successRedirect: "/admin/accounts"
      failureRedirect: "/admin/accounts"
    ).apply this, arguments
