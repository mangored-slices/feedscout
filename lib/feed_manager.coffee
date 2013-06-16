Q = require('q')

class FeedManager
  constructor: (@accounts) ->

  fetch: ->
    Q.all(
      @accounts.map (account) -> account.fetcher().fetch()

    ).then (feeds) =>
      console.log(feeds)
      # Combine feeds
      # sync

  sync: ->

  # Get latest `n` stories from given accounts.
  get: (n=20) ->
