Strategy = require("passport-tumblr").Strategy
passport = require("passport")

module.exports =

  ###
  # Endpoint for Tumblr OAuth.
  ###

  auth: (req, res, next) ->
    account = res.locals.account
    id = res.locals.account.id

    # Dynamically set the strategy.
    passport.use new Strategy(
      consumerKey: account.getCredentials().consumerKey
      consumerSecret: account.getCredentials().consumerSecret
      callbackURL: "http://#{req.headers.host}/auth/tumblr/callback"
    , (token, tokenSecret, profile, done) ->
      console.log profile
      account.extendCredentials
        accessToken: token
        accessTokenSecret: tokenSecret
        username: profile.username
        userId: null
        displayName: profile._json?.response?.user?.blogs?[0]?.title
        photo: null

      account.save().success(->
        done()
      ).error (e) ->
        done e
    )

    passport.authenticate("tumblr").apply this, arguments

  ###
  # Callback for tumblr auth.
  # Does nothing, really... since it's the Strategy that handles things.
  ###

  callback: (req, res, next) ->
    passport.authenticate("tumblr",
      successRedirect: "/admin/accounts"
      failureRedirect: "/admin/accounts"
    ).apply this, arguments
