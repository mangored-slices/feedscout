var Account = require('../../lib/models/account');
var FeedFetcher = require('../../lib/feed_fetcher');
var app = require('../..');
var wrap = require('../../lib/utils').wrap;
var setter = require('../../lib/utils').setter;


app.get('/feed.json',
  fetchFeed,
  getAccounts,
  getTwitter);
  // feed);

app.get('/sources.json',
  getAccounts,
  sources);

// ----------------------------------------------------------------------------
// Actions

function feed(req, res, next) {
  var obj = {
    date: {
      'from': new Date(),
      'to': new Date()
    }
  };

  app.log.log(res.locals.accounts);

  res.json(obj);
}

function getTwitter(req, res, next) {
  wrap(Account.find({ where: { name: 'twitter' }}), function(err, account) {
    if (err) return next(404);

    account.fetcher().fetch(function(err, data) {
      if (err) next(err);
      res.json(data);
    });
  });
}

function sources(req, res) {
  var accounts = res.locals.accounts;

  res.json({
    sources: accounts
  });
}

// ----------------------------------------------------------------------------
// Filters

/**
 * Fetches available accounts.
 * Sets `locals.accounts`
 */

function getAccounts(req, res, next) {
  wrap(Account.findAll(), function(err, accounts) {
    if (err) return next(404);

    res.locals.accounts = accounts;
    next();
  });
}

/**
 * Asks the feed fetcher to fetch feeds dynamically.
 * Sets `locals.feeds`
 */

function fetchFeed(req, res, next) {
  FeedFetcher.fetch(true, function(err, data) {
    if (err) return next("Can't fetch feeds");

    res.locals.feeds = data;
    next();
  });
}
