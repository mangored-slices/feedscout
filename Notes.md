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


## Flickr

 * Just the username

## Tumblr

 * Register at http://www.tumblr.com/oauth/register
 * No callback URL or icon
 * See it listed in http://www.tumblr.com/oauth/apps
 * Save the __OAuth Consumer Key__

## Twitter

 * https://dev.twitter.com/apps/new
 * Get __Consumer Key__ and __Consumer Secret__ here
 * Click "create access token"
 * Get __Access Token__ and __Access Token Secret__

https://github.com/jdub/node-twitter

## Instagram

 * http://instagram.com/developer
 * Go to "Manage Clients"
 * Sign in and create a new client
 * Redirect URI = http://127.0.0.1:8000/instagram/auth/
 * Get __client ID__ and __secret__
 * Navigate to that URL above
 * __access token__ and __user id__

https://github.com/teleportd/instagram-node
https://github.com/mckelvey/instagram-node-lib
