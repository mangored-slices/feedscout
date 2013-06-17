var fs = require('fs');

xit("flickr", function() {
  var xml_digester = require("xml-digester");
  var digester = xml_digester.XmlDigester({});

  var xml = fs.readFileSync('./test/fixtures/flickr.xml', 'utf-8');

  digester.digest(xml, function(err, result) {
    if (err) { 
      console.log(err);
    } else {
      console.log(result.feed.entry[0]);

      var entry = result.feed.entry[0];
      var url = entry.link[0].href;
      var image = entry.link[2].href;
    }
  });
});
