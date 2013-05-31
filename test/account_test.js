require('./setup');

var Account = require('../lib/models/account');

describe('Accounts', function() {
  beforeEach(createTwitter);
  beforeEach(createInstagram);

  it("/sources.json", function(done) {
    request(app)
      .get('/sources.json')
      .expect(200, function(err, data) {
        var result = data.res.body;
        
        assert.equal(2, result.sources.length);
        assert.equal('mytwitter', result.sources[0].name);
        assert.equal('twitter', result.sources[0].service);
        assert.equal('rstacruz', result.sources[0].username);

        assert.equal('instagram', result.sources[1].service);
        done();
      });
  });
});

function createTwitter(done) {
  var account = Account.build({
    service: 'twitter',
    name: 'mytwitter'
  });

  account.setCredentials({
    username: "rstacruz",
    displayName: "Rico Sta. Cruz",
    photoUrl: "http://imgur.com/a.jpg"
  });

  wrap(account.save(), done);
}

function createInstagram(done) {
  var account = Account.build({
    service: 'instagram',
    name: 'myinstagram'
  });

  account.setCredentials({
    username: "ricostacruz",
    displayName: "Rico Sta. Cruz",
    photoUrl: "http://imgur.com/b.jpg"
  });

  wrap(account.save(), done);
}
