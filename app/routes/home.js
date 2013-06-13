var app = require('../..');

app.get('/',
  home);

function home(req, res) {
  res.render('index');
}
