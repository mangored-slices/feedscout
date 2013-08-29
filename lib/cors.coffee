module.exports = Cors = (req, res, next) ->
  # 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Accept'
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Credentials', true
  res.header 'Access-Control-Allow-Methods', 'GET, OPTIONS'
  res.header 'Access-Control-Allow-Headers', 'Content-Type'
  next()
