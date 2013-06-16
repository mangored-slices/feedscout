module.exports = {
  /**
   * Returns an Express handler that:
   * runs a promise and sets the res.locals variable `name` to its result.
   * Skips to a 404 if the return value is falsy.
   *
   *     app.get '/posts', 
   *       local('posts',
   *         -> Post.findAll()),
   *
   *       local('accounts',
   *         -> Accounts.findAll()),
   *
   *       (req, res) ->
   *         res.render 'index', posts: res.locals.posts
   */
  local: function(name, fn) {
    return function(req, res, next) {
      return fn.apply(res.locals, arguments).then(function(data) {
        if (!data) {
          return next(404);
        }
        res.locals[name] = data;
        return next();
      }, next);
    };
  },

  /**
   * Returns an Express handler that:
   * runs a promise and sets the res.locals variable `name` to its result.
   */
  localSet: function(name, fn) {
    return function(req, res, next) {
      return fn.apply(res.locals, arguments).then(function(data) {
        res.locals[name] = data;
        return next();
      }, next);
    };
  },

  /**
   * Returns an Express handler that:
   * Runs a function, with `this` bound to locals to make things easier.
   */
  run: function(fn) {
    return function(req, res, next) {
      return fn.apply(res.locals, arguments);
    };
  },

  redirect: function(url) {
    return function(req, res) {
      return res.redirect(url);
    };
  }
};
