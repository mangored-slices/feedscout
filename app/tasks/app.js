function read(callback) {
  var data = '';
  process.stdin.resume();
  process.stdin.on('data', function(chunk) { data += chunk.toString(); });
  process.stdin.on('end', function() { callback(data); });
}

module.exports = function(app, cli) {
  cli
    .command('gen-admin')
    .description('Generates admin credentials')
    .action(function() {
      cli.password("password: ", "*", generate);
    });

  cli
    .command('backup-restore')
    .description('Restores from a backup')
    .action(function() {
      read(function(data) {
        app.load();
        var Account = require('../../lib/models/account');

        data = JSON.parse(data);
        data.accounts.forEach(function(account) {
          console.log(account);
          Account.build(account).setCredentials(account.credentials).save();
        });
      });
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
