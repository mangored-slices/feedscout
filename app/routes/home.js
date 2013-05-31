var express = require('express');
var passport = require('passport');
var TwitterStrategy = require('passport-twitter').Strategy;
var Account = require('../../lib/models/account');
var admin = require('./admin_filters');
var wrap = require('../../lib/utils').wrap;
var app = require('../..');

app.get('/',
  home);

app.all('/admin*',
  admin.authenticate);

app.get('/admin',
  redirect('/admin/accounts'));

app.get('/admin/accounts',
  getAccounts,
  index);

// New form
app.get('/admin/accounts/new/twitter',
  newTwitter);

// Get-edit
app.get('/admin/accounts/:id',
  getAccount,
  show);

// Create
app.post('/admin/accounts',
  create);

// Destroy
app.del('/admin/accounts/:id',
  getAccount,
  destroy);

// Oauth
app.get('/admin/accounts/:id/auth/twitter',
  getAccount,
  ensureAccountIs('twitter'),
  passportTwitter);

// Oauth callback
app.get('/admin/accounts/:id/auth/twitter/callback',
  getAccount,
  ensureAccountIs('twitter'),
  passportTwitterCallback);

// ----------------------------------------------------------------------------
// Actions

function home(req, res) {
  res.render('index');
}

function index(req, res) {
  res.render('accounts/index');
}

function newTwitter(req, res) {
  res.locals.account = Account.build({
    service: 'twitter',
    name: 'twitter'
  });
  res.render('accounts/new-twitter');
}

function show(req, res) {
  var account = res.locals.account;
  res.render('accounts/show-' + account.service);
}

/*
 * @input body.account
 * @output render
 */
function create(req, res) {
  var data = req.body.account;

  var account = res.locals.account =
    Account.build(data);

  account.setCredentials(data.credentials);

  var service = account.service;

  account.save().success(function() {
    res.redirect('/admin/accounts/' + account.id);
  }).error(function() {
    res.render('accounts/new-'+service);
  });
}

function destroy(req, res, next) {
  var account = res.locals.account;
  account.destroy()
    .success(function() {
      res.redirect('/admin/accounts');
    })
    .error(function(err) { next(err); });
}

// ----------------------------------------------------------------------------
// Filters

/*
 * Retrieves an account for editing.
 */
function getAccount(req, res, next) {
  var id = req.params.id;

  wrap(Account.find(id), function(err, account) {
    if (err) return next(404);

    res.locals.account = account;
    next();
  });
}

/*
 * (Filter) ensures the account is of a given service.
 * Useful for OAuth callbacks.
 */
function ensureAccountIs(service) {
  return function(req, res, next) {
    var account = res.locals.account;
    if (account.service !== service)
      return next(new Error("Wrong service (" + account.service + " is not " + service + ")"));
    next();
  };
}

/*
 * Retrieves the list of accounts for indexing
 */
function getAccounts(req, res, next) {
  wrap(Account.findAll(), function(err, accounts) {
    if (err) return next(404);

    res.locals.accounts = accounts;
    next();
  });
}

function nil(req, res) {
  res.send('');
}

function redirect(url) {
  return function(req, res) { res.redirect(url); };
}

// ----------------------------------------------------------------------------
// Twitter OAuth

/*
 * Endpoint for Twitter OAuth.
 */
function passportTwitter(req, res, next) {
  var account = res.locals.account;
  var id = res.locals.account.id;

  passport.use(new TwitterStrategy({
    consumerKey: account.getCredentials().consumerKey,
    consumerSecret: account.getCredentials().consumerSecret,
    callbackURL: "http://127.0.0.1:4567/admin/accounts/"+id+"/auth/twitter/callback"
  },
  function(token, tokenSecret, profile, done) {
    // Save credentials
    account.extendCredentials({
      accessToken: token,
      accessTokenSecret: tokenSecret,
      username: profile.username,
      displayName: profile.displayName,
      photo: profile.photos[0].value
    });

    account.save().success(function() {
      done();
    }).error(function(e) {
      done(e);
    });
  }));

  passport.authenticate('twitter').apply(this, arguments);
}

/*
 * Callback for twitter auth.
 * Does nothing, really... since it's the Strategy that handles things.
 */
function passportTwitterCallback(req, res, next) {
  var id = req.params.id;
  passport.authenticate('twitter', {
      successRedirect: '/admin/accounts/'+id,
      failureRedirect: '/admin/accounts/'+id
  }).apply(this, arguments);
}
