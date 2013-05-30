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

  console.log('# Save this as config/admin.yml');
  console.log('');
  console.log('default:');
  console.log('  username: "admin"');
  console.log('  password: "'+digest+'"');
}
