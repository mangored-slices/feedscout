require "./setup"

Q = require 'q'
fs = require 'fs'
FlickrFetcher = require '../lib/flickr_fetcher'

describe 'FlickrFetcher', ->
  beforeEach ->
    @fetcher = new FlickrFetcher("...")

  it "flickr", pt ->
    xml = fs.readFileSync("./test/fixtures/flickr.xml", "utf-8")

    Q.try =>
      @fetcher.parseXml(xml)

    .then (data) =>
      entries = @fetcher.getEntries(data)

      console.log entries
