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
  opts =
    username: process.env['ADMIN_USERNAME'] or creds.username
    password: process.env['ADMIN_PASSWORD'] or creds.password

  user is opts.username and hash(pass) is opts.password

###
# Authentication middleware.
###
AdminAuth.authenticate =
  express.basicAuth(AdminAuth.auth, 'Admin area')

