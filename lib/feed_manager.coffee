Q = require 'q'
_ = require 'underscore'
Moment = require 'moment'
Entry = require './models/entry'

module.exports = class FeedManager
  constructor: (@accounts) ->

  ###
  # Fetches new updates from given account.
  ###
  fetch: ->
    Q.all \
      @accounts.map (account) =>
        account.fetcher().fetch()
        .then (entries) =>
          @sync(account, entries)

  ###
  # Pushes `entries` into database.
  # Returns a promise; promise is fulfilled with nothing
  ###
  sync: (account, entries) ->
    # Get old entries
    Q.try ->
      entries = _(entries).sortBy (item) -> +Moment(item.date)

      range =
        from: Moment(_(entries).first().date).toDate()
        to: Moment(_(entries).last().date).toDate()

      Entry.findAll(where: ["accountId = ? AND date >= ? AND date <= ?", account.id, range.from, range.to])

    # Destroy old entries
    .then (oldEntries) ->
      Q.all oldEntries.map (e) -> e.destroy()

    # Push new entries
    .then ->
      Q.all entries.map (entry) ->
        Entry.build(
          accountId: entry.source.id
          date: entry.date
          text: entry.text
          image: entry.image
          fulltext: entry.fulltext
        ).save()

  # Get latest `n` stories from given accounts.
  get: (n=20) ->
