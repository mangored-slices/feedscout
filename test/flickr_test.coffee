require "./setup"

Q = require 'q'
fs = require 'fs'
FlickrFetcher = require '../lib/flickr_fetcher'

describe 'FlickrFetcher', ->
  @timeout 5000

  beforeEach ->
    @fetcher = new FlickrFetcher("17053755@N00")

  it "flickr", pt ->
    xml = fs.readFileSync("./test/fixtures/flickr.xml", "utf-8")

    Q.try =>
      @fetcher.parseXml(xml)

    .then (data) =>
      entries = @fetcher.getEntries(data)

      # console.log entries

  it.only 'fetchentries', pt ->
    @fetcher.fetchEntries()
    .then (data) =>
      console.log(data)

