app = require '../..'
_ = require 'underscore'
Q = require 'q'
Sq = require 'sequelize'
Moment = require 'moment'

module.exports = Entry = app.sequelize().define("Entry",

  account_id: Sq.INTEGER
  postType: Sq.STRING

  date: Sq.DATE
  image: Sq.STRING
  image_large: Sq.STRING
  text: Sq.TEXT
  fulltext: Sq.TEXT
  url: Sq.STRING
  data: Sq.TEXT
,
  classMethods:

    toFeedJSON: (entries) ->
      data = {
        range: {
          from: _(entries).last()?.date,
          to: _(entries).first()?.date
        }
        sources: _.uniq((entries.map (e) -> e.account?.toJSON()), false, (a) -> a?.id)
        entries: entries.map (e) -> e.toFeedJSON()
      }

  instanceMethods:

    # Assumes eager-loaded source
    toFeedJSON: ->
      source: @account?.toJSON()
      date: Moment(@date).format()
      image: @image
      text: @text
      fulltext: @fulltext
      url: @url
)

Account = require("./account")
Account.hasMany Entry, foreignKey: 'account_id'
Entry.belongsTo Account, foreignKey: 'account_id'
