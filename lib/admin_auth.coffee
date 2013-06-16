app     = require('..')
hash    = require('../lib/utils').hashify
express = require('express')

module.exports = AdminAuth = {}
###
# Authenticates a user.
#
#     auth('admin', 'mypassword');
#     //=> true or false
###
AdminAuth.auth = (user, pass) ->
  creds = app.conf("admin")
  user is creds.username and hash(pass) is creds.password

###
# Authentication middleware.
###
AdminAuth.authenticate =
  express.basicAuth(AdminAuth.auth, 'Admin area')

