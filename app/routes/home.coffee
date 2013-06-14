app = require("../..")

# ----------------------------------------------------------------------------

home = (req, res) ->
  res.render "index"

app.get "/",
  home
