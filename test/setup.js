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

/**
 * Promise test helper: allow
 */
global.pt = function(fn) {
  return function(done) {
    fn().then(
      function(data) { done(undefined, data); },
      function(err) { done(new Error("Promised failed: " + err)); });
  };
};

/**
 * JSON helper - great for comparisons
 */

global.json = function(obj) {
  return JSON.stringify(obj);
};

exports.loadApp = function() {
  app.load('test');
};

/**
 * DB sync
 */
exports.sync = pt(function() {
  return app.sequelize().sync({ force: true });
});
