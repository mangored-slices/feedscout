var expo = require('expo');
var express = require('express');
var passport = require('passport');

module.exports = function(app) {
  var token = app.conf('secret_token') || '...........';

  app.set('view engine', 'jade');
  app.configure('development', function() {
    app.set('throw errors', true);
    app.use(express.favicon());
    app.use(express.logger('dev'));
  });
  app.configure('production', function() {
    app.set('log errors', true);
  });
  app.use(express['static'](app.path('public')));
  app.use(express.cookieParser(token));
  app.use(express.bodyParser());
  app.use(express.session({ key: 'session', secret: token }));
  app.use(express.methodOverride());
  app.use(passport.initialize());
  app.use(passport.session());
  app.use(app.router);
  app.set('sequelize options', {
    omitNull: true,
    defines: { timestamps: false }
  });
  app.configure('development', function() {
    app.use(expo.errorHandler(express.errorHandler()));
  });
};
