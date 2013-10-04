Q = require 'q'
_ = require 'underscore'
Moment = require 'moment'
Account = require './models/account'
Entry = require './models/entry'

module.exports = class FeedManager
  constructor: (@accounts) ->
    # Only work with authorized accounts
    @accounts = _(@accounts).select (a) -> a?.isAuthorized()

  ###
  # Fetches new updates from given account.
  ###
  fetch: ->
    Q.all \
      @accounts.map (account) =>
        Q.try =>
          account.updated_at = new Date()
          account.save()

        .then =>
          account.fetcher()?.fetch()
          .then (entries) =>
            @sync(account, entries)
          .then null, ->
            App.log.error "FeedManager: account '#{account.name}' failed to fetch, still continuing"

  ###
  # Pushes `entries` into database.
  # Returns a promise; promise is fulfilled with nothing
  ###
  sync: (account, entries) ->

    # Get old entries to be deleted
    Q.try ->
      entries = _(entries).sortBy (item) -> +Moment(item.date)

      if entries.length > 0
        range =
          from: Moment(_(entries).first().date).toDate()
          to: Moment(_(entries).last().date).toDate()

        Entry.findAll(where: ["account_id = ? AND date >= ? AND date <= ?", account.id, range.from, range.to])
      else
        Entry.findAll()

    # Destroy old entries
    .then (oldEntries) ->
      Q.all oldEntries.map (e) -> e.destroy()

    # Push new entries
    .then ->
      Q.all entries.map (entry) ->
        Entry.build(
          account_id: entry.account_id
          date: entry.date
          text: entry.text
          image: entry.image
          image_large: entry.image_large
          image_ratio: entry.image_ratio
          fulltext: entry.fulltext
          url: entry.url
        ).save()

  # Checks last updated time.
  # Picks out the one that was updated earliest.
  updated_at: ->
    dates = _(@accounts).pluck('updated_at')
    _(dates).min()

  # Age in miliseconds
  age: ->
    (+new Date() - @updated_at())

  # Get latest `n` stories from given accounts.
  # Returns a promise.
  get: (n=50) ->
    # Account for empty accounts
    ids = @accounts.map (a) -> a.id
    seq = Entry.daoFactoryManager.sequelize
    dialect = seq.options.dialect

    if ids.length > 0
      where = if dialect is 'postgres'
        "account_id = ANY(ARRAY[#{ids.join(',')}])"
      else
        ["account_id IN (?)", ids]

      Entry.findAll(where: where, limit: n, order: "date DESC", include: [ Account ])

    else
      # For empty accounts, return an empty set
      Q.promise (ok) -> ok([])
