Dev notes
=========

    FeedFetcher.fetch(true, function(err, data) {
    });

RESTful API
-----------

``` javascript
$ curl http://api.yoursite.com/feed.json
{
  /* The range of this feed */
  date: {
    from: '20130520T142300Z',
    to: '20130520T142300Z'
  },

  posts: [
    date: '20130520T142300Z',
    post_type: 'tweet',
    source: {
      name: 'twitter',
      service: 'twitter',
      username: 'rstacruz',
    },
    image_url: 'http://pic.twitter.com/....jpg',
    text: 'This is a great thing!',
    fulltext: ''
  ]
}
```

``` json
$ curl http://api.yoursite.com/feed.json?feeds=twitter,instagram
```


Services
--------

### Flickr

 * Just the username

 * http://www.flickr.com/services/apps/create/

API:

 * http://www.flickr.com/services/api/
 * http://www.flickr.com/services/api/flickr.activity.userPhotos.html

### Tumblr

OAuth directions:

 * http://www.tumblr.com/oauth/register
 * No callback URL or icon
 * See it listed in http://www.tumblr.com/oauth/apps
 * Save the `OAuth Consumer Key`

API:

    http://www.tumblr.com/docs/en/api/v2#posts

### Twitter

OAuth directions:

 * https://dev.twitter.com/apps/new
 * Get `Consumer Key` and `Consumer Secret` here
 * Click "create access token"
 * Get `Access Token` and `Access Token Secret`

https://github.com/jdub/node-twitter

### Instagram

 * http://instagram.com/developer
 * Go to "Manage Clients"
 * Sign in and create a new client
 * Redirect URI = http://127.0.0.1:8000/instagram/auth/
 * Get `client ID` and `secret`
 * Navigate to that URL above
 * `access token` and `user id`
