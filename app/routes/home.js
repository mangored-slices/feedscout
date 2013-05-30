var express = require('express');
module.exports = function(app) {
  app.get('/',
    nil());

  app.all('/admin*',
    express.basicAuth(auth, 'Admin area'));

  app.get('/admin',
    redirect('/admin/accounts'));

  // index
  app.get('/admin/accounts',
    nil());

  // new
  app.get('/admin/accounts/new',
    nil());

  // show
  app.get('/admin/accounts/:id',
    setAccount,
    nil());

  // create
  app.post('/admin/accounts',
    nil());

  // update
  app.post('/admin/accounts/:id',
    nil());

  // delete
  app.del('/admin/accounts/:id',
    setAccount,
    nil());

  function auth(user, pass) {
    var creds = app.conf('admin');
    var hash = require('../../lib/utils').hashify;
    return user === creds.username && hash(pass) === creds.password;
  }

  // Retrieve an account.
  function setAccount(req, res, next) {
    next();
  }

  function nil() {
    return function(req, res) { res.json({ok: true}); };
  }

  function render(view) {
    return function(req, res) { res.render(view); };
  }

  function redirect(url) {
    return function(req, res) { res.redirect(url); };
  }
};
