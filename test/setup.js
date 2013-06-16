// Globals/packages
var chai = require('chai');
global.assert = chai.assert;
global.expect = chai.expect;
global.request = require('supertest');
global.Q = require('q');
global.app = require('../app');

// Initialize
app.set('env', 'test');
chai.should();
require('./helpers');

/**
 * Loads the app
 * before(Setup.loadApp);
 */

exports.loadApp = function() {
  app.load('test');
};

/**
 * DB sync - wipes the database
 * before(Setup.sync);
 */

exports.sync = pt(function() {
  return app.sequelize().sync({ force: true });
});
