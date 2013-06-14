app     = require('../..')
hash    = require('../../lib/utils').hashify
express = require('express')

###
 * Authenticates a user.
 *
 *     auth('admin', 'mypassword');
 *     //=> true or false
###

exports.auth = (user, pass) ->
  creds = app.conf("admin")
  user is creds.username and hash(pass) is creds.password

###
 * Authentication middleware.
###

exports.authenticate = 
  express.basicAuth(exports.auth, 'Admin area')

