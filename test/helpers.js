/**
 * Promise test helper
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
