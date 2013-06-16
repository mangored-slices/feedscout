/**
 * Promise test helper
 */
global.pt = function(fn) {
  return function(done) {
    var promise = fn.apply(this);
    if (!promise.then) return done(new Error("Object "+promise+" is not a promise"));

    promise.then(
      function(data) { done(undefined, data); },
      function(err) { done(err); });
  };
};

/**
 * JSON helper - great for comparisons
 */

global.json = function(obj) {
  return JSON.stringify(obj);
};
