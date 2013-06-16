module.exports = function(app, cli) {
  cli
    .command('gen-admin')
    .description('Generates admin credentials')
    .action(function() {
      cli.password("password: ", "*", generate);
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
