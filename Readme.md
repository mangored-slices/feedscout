# feedscout

Setup:

    $ npm install

Set up config:

    $ ./run gen-admin

    $ cp config/database.yml{.example,}

Run:

    $ ./run server

For more info:

    $ ./run --help

Admin
-----

Go to `http://.../admin`. The password is likely `password`, it's stored in 
`config/admin.yml`.

Change admin password
---------------------

    $ ./run gen-admin

API
---

    $ curl http://feeds.app.com/sources.json

    $ curl http://feeds.app.com/feed.json
