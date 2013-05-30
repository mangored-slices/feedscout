var app = require('../..');
var hash = require('../../lib/utils').hashify;
var express = require('express');

/**
 * Authenticates a user.
 */

exports.auth = function(user, pass) {
  var creds = app.conf('admin');
  return user === creds.username && hash(pass) === creds.password;
};

/**
 * Authentication middleware.
 */

exports.authenticate = 
  express.basicAuth(exports.auth, 'Admin area');

