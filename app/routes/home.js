var express = require('express');

var passport = require('passport');
var TwitterStrategy = require('passport-twitter').Strategy;

module.exports = function(app) {
  var admin = require('./admin_filters');

  app.get('/',
    nil);

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

  app.post('/admin/accounts/:id',
    getAccount,
    update);

  app.del('/admin/accounts/:id',
    getAccount,
    destroy);

  app.get('/admin/accounts/:id/auth/twitter',
    getAccount,
    ensureAccountIs('twitter'),
    passportTwitter);

  var Account = require('../../lib/models/account');

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

    var account = Account.build(data);
    account.setCredentials(data.credentials);
    res.locals.account = account;

    var service = account.service;

    account.save().success(function() {
      res.redirect('/admin/accounts/' + account.id);
    }).error(function() {
      res.render('accounts/new-'+service);
    });
  }

  function update(req, res) {
  }

  function destroy(req, res) {
  }

  /*
   * Retrieves an account for editing.
   */
  function getAccount(req, res, next) {
    var id = req.params.id;

    wrap(Account.find(id), next, function(account) {
      res.locals.account = account;
    });
  }

  function ensureAccountIs(service) {
    return function(req, res, next) {
      var account = res.locals.account;
      if (account.service !== service)
        return next(new Error("Wrong service (" + account.service + " is not " + service + ")"));
      next();
    };
  }

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

  app.get('/admin/accounts/:id/auth/twitter/callback', function(req, res, next) {
    var id = req.params.id;
    passport.authenticate('twitter', {
        successRedirect: '/admin/accounts/'+id,
        failureRedirect: '/admin/accounts/'+id
    }).apply(this, arguments);
  });

  /*
   * Retrieves the list of accounts for indexing
   */
  function getAccounts(req, res, next) {
    wrap(Account.findAll(), next, function(accounts) {
      res.locals.accounts = accounts;
    });
  }

  function nil(req, res) {
    res.send('');
  }

  function redirect(url) {
    return function(req, res) { res.redirect(url); };
  }

  /*
   * Wraps a Sequelize promise
   */
  function wrap(promise, next, callback) {
    promise
      .success(function(data) {
        if (!data) return next(404);
        if (callback) callback(data);
        next();
      })
      .error(function(err) {
        next(err);
      });
  }
};
