Strategy = require("passport-flickr").Strategy
passport = require("passport")

module.exports =

  ###
  # Endpoint for flickr OAuth.
  ###

  auth: (req, res, next) ->
    account = res.locals.account
    id = res.locals.account.id

    # Dynamically set the strategy.
    passport.use new Strategy(
      consumerKey: account.getCredentials().consumerKey
      consumerSecret: account.getCredentials().consumerSecret
      callbackURL: "http://#{req.headers.host}/auth/flickr/callback"
    , (token, tokenSecret, profile, done) ->
      account.extendCredentials
        accessToken: token
        accessTokenSecret: tokenSecret
        username: profile.displayName
        userId: profile.id
        displayName: profile.fullName
        photo: null

      account.save().success(->
        done()
      ).error (e) ->
        done e
    )

    passport.authenticate("flickr").apply this, arguments

  ###
  # Callback for flickr auth.
  # Does nothing, really... since it's the Strategy that handles things.
  ###

  callback: (req, res, next) ->
    passport.authenticate("flickr",
      successRedirect: "/admin/accounts"
      failureRedirect: "/admin/accounts"
    ).apply this, arguments
