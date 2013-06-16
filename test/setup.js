require('mocha-as-promised')();
// Chai.js (http://chaijs.com/)
var chai = require('chai');
global.assert = chai.assert;
global.expect = chai.expect;
chai.should();

// Supertest (https://github.com/visionmedia/supertest)
global.request = require('supertest');

global.Q = require('q');

// Load the app
global.app = require('../app');
app.set('env', 'test');
global.wrap = require('../lib/utils').wrap;

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
