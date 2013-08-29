module.exports = function(app, cli) {
  cli
    .command('gen-admin')
    .description('Generates admin credentials')
    .action(function() {
      cli.password("password: ", "*", generate);
    });

  cli
    .command('fetch')
    .description('Fetches')
    .action(function(name) {
      app.load();
      var Account = require('../../lib/models/account');

      Account.find({ where: { name: name }})
      .then(function(account) {
        if (!account) {
          console.log("  ... no such account ["+name+"]");
        }
        else {
          console.log("  ... ["+name+"]: getting fetcher");

          var fetcher = account.fetcher();
          console.log("  ... ["+name+"]: fetching");

          return fetcher.fetch()
          .then(function(entries) {
            console.log(entries);
            console.log("  ... ok");
          });
        }
      })
      .then(null, function(err) {
        console.log("  ... err: ");
        console.log(err);
        console.log("  ... err");
        throw err;
      });
    });
};

function generate(pwd) {
  var hashify = require('../../lib/utils').hashify;
  var digest = hashify(pwd);

  process.stdout.write('# Save this as config/admin.yml\n\n');
  process.stdout.write('default:\n');
  process.stdout.write('  username: "admin"\n');
  process.stdout.write('  password: "'+digest+'"\n');
}
