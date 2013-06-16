Q = require 'q'
_ = require 'underscore'
Moment = require 'moment'

module.exports = class FeedManager
  constructor: (@accounts) ->

  ###
  # Fetches new updates from given account.
  ###
  fetch: ->
    Q.promise (ok, fail) =>
      Q.all(
        @accounts.map (account) -> account.fetcher().fetch()

      ).then (feeds) =>
        # Combine into one feed
        feed = _(feeds).flatten()
        feed = _(feed).sortBy (item) -> 0 - +Moment(item.date)

        # Push to database and return the value
        @sync(feed)
        ok(feed)

      .done(fail)

  sync: (feed) ->

  # Get latest `n` stories from given accounts.
  get: (n=20) ->
