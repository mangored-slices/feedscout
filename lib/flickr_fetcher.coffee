Q = require 'q'
Moment = require 'moment'

module.exports = class FlickrFetcher

  constructor: (account) ->
    if account.getCredentials
      user = account.getCredentials()

      if !user or !user.userId
        throw new Error("FlickrFetcher: no userId")

      # General
      @account = account
      @username = user.userId
      @type = "flickr"

      # Flickr-specific
      @userId = user.userId

    else
      @userId = account

  fetch: ->
    Q.promise (ok, fail) =>
      ok()

  ###
  # Parses a given XML string into lol
  ###
  parseXml: (xml) ->
    Q.promise (ok, fail) =>
      xml_digester = require "xml-digester"
      digester = xml_digester.XmlDigester({})
      xml_digester._logger.level(xml_digester._logger.ERROR_LEVEL)

      digester.digest xml, (err, result) =>
        return fail(err)  if err
        ok(result)

  ###
  # Fishes out entries from a JSON of the RSS
  ###
  getEntries: (rss) ->
    rss.feed.entry.map (entry) =>
      item =
        url: entry.link[0].href
        image: entry.link[2].href
        date: Moment(entry.published).toDate()
        title: entry.title
