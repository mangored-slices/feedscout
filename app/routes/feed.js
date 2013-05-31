var Account = require('../../lib/models/account');
var FeedFetcher = require('../../lib/feed_fetcher');
var wrap = require('./helpers').wrap;
var app = require('../..');

app.get('/feed.json',
  fetchFeed,
  feed);

app.get('/sources.json',
  getAccounts,
  sources);

// ----------------------------------------------------------------------------

function feed(req, res) {
  var obj = {
    date: {
      'from': new Date(),
      'to': new Date()
    }
  };
  res.json(obj);
}

function sources(req, res) {
  var accounts = res.locals.accounts;

  res.json({
    sources: accounts
  });
}

// ----------------------------------------------------------------------------

function getAccounts(req, res, next) {
  wrap(Account.findAll(), next, function(accounts) {
    res.locals.accounts = accounts;
  });
}

function fetchFeed(req, res, next) {
  FeedFetcher.fetch(true, function(err, data) {
    if (err) return next(err);

    res.locals.feed = data;
    next();
  });
}
