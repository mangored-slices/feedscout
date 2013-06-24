Q = require 'q'
Moment = require 'moment'
Request = require 'superagent'

module.exports = class FlickrFetcher

  constructor: (account) ->
    @request = Request

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

  ###
  # Returns a promise that yields an array of entries
  ###
  fetch: ->
    Q.promise (ok, fail) =>
      @request.get(@url()).end (err, data) ->
        if err then fail(err) else ok(data)

    .then (result) =>
      unless result.text
        throw new Error("No result text")

      @parseXml(result.text)

    .then (rss) =>
      @getEntries(rss)

  ###
  # Parses a given XML string into stuff
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
  # Returns feed URL
  # See: http://www.flickr.com/services/feeds/docs/photos_public/
  ####
  url: ->
    "http://api.flickr.com/services/feeds/photos_public.gne?id=#{@userId}"

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
