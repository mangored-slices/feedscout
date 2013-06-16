# Express/Q helpers
module.exports = E =
  # Returns an Express handler that:
  # runs a promise and sets the res.locals variable `name` to its result.
  #
  #     app.get '/posts', 
  #       E.local('posts', -> Post.findAll()),
  #       (req, res) ->
  #         res.render 'index', posts: res.locals.posts
  #
  local: (name, fn) ->
    return (req, res, next) ->
      fn.apply(res.locals, arguments).then(
        (data) ->
          res.locals[name] = data
          next()
      , next)

  # Returns an Express handler that:
  # Runs a function, with `this` bound to locals to make things easier.
  run: (fn) ->
    return (req, res, next) ->
      fn.apply(res.locals, arguments)

