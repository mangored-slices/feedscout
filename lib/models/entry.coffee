app = require '../..'
_ = require 'underscore'
Q = require 'q'
Sq = require 'sequelize'
Moment = require 'moment'

module.exports = Entry = app.sequelize().define("Entry",

  accountId: Sq.STRING
  postType: Sq.STRING

  date: Sq.DATE
  image: Sq.STRING
  text: Sq.TEXT
  fulltext: Sq.TEXT
  url: Sq.STRING
,
  classMethods:

    toFeedJSON: (entries) ->
      Q.all(entries.map (e) -> e.toFeedJSON())
      .then (entryData) ->
        data = {
          range: {
            from: _(entries).last()?.date,
            to: _(entries).first()?.date
          }
          entries: entryData
        }

  instanceMethods:

    toFeedJSON: ->
      @getAccount()
      .then (account) =>
        source: account.toJSON()
        date: Moment(@date).format()
        image: @image
        text: @text
        fulltext: @fulltext
        url: @url
)

Account = require("./account")
Account.hasMany Entry
Entry.belongsTo Account
