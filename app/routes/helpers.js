/*
 * Wraps a Sequelize promise for a filter
 */
module.exports.wrap = function (promise, next, callback) {
  promise
    .success(function(data) {
      if (!data) return next(404);
      if (callback) callback(data);
      next(null, data);
    })
    .error(function(err) {
      next(err);
    });
};
