module.exports = class FlickrFetcher

  constructor: (account) ->
    user = account.getCredentials()

    if !user or !user.userId
      throw new Error("FlickrFetcher: no userId")

    # General
    @account = account
    @username = user.userId
    @type = "flickr"

    # Flickr-specific
