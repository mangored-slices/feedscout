app = require("../..")
Sq = require("sequelize")

module.exports = Entry = app.sequelize().define("Entry",

  accountId: Sq.STRING
  postType: Sq.STRING

  image: Sq.STRING
  text: Sq.TEXT
  fulltext: Sq.TEXT
)

Account = require("./account")
Account.hasMany Entry
Entry.belongsTo Account
