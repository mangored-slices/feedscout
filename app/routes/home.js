var express = require('express');
module.exports = function(app) {
  var admin = require('./admin_filters');

  app.get('/',
    nil);

  app.all('/admin*',
    admin.authenticate);

  app.get('/admin',
    redirect('/admin/accounts'));

  app.get('/admin/accounts',
    setAccounts,
    index);

  app.get('/admin/accounts/new',
    new_);

  app.get('/admin/accounts/:id',
    setAccount,
    show);

  app.post('/admin/accounts',
    create);

  app.post('/admin/accounts/:id',
    setAccount,
    update);

  app.del('/admin/accounts/:id',
    setAccount,
    destroy);

  function index(req, res) {
    res.render('accounts-index');
  }

  function new_(req, res) {
    res.render('accounts-new');
  }

  function show(req, res) {
    res.send('');
  }

  function create(req, res) {
  }

  function update(req, res) {
  }

  function destroy(req, res) {
  }

  // Retrieve an account.
  function setAccount(req, res, next) {
    next();
  }

  function setAccounts(req, res, next) {
    res.locals.accounts = ['tom', 'harry'];
    next();
  }

  function nil(req, res) {
    res.send('');
  }

  function redirect(url) {
    return function(req, res) { res.redirect(url); };
  }
};
