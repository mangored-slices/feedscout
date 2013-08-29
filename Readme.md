# feedscout

Setup:

    $ npm install

Set up config:

    $ ./run gen-admin      # Make an admin password
    $ cp config/database.yml{.example,}

    $ ./run db-create
    $ ./run db-sync

Run:

    $ ./run server

For more info:

    $ ./run --help

Tests
-----

    $ npm test

Admin
-----

Go to `http://localhost:4567/admin`.
(The password is likely `password`, it's stored in `config/admin.yml`.)

Deployment
----------

    # Set up the host
      $ heroku create
      $ git push heroku master

    # Start a web process
      $ heroku ps:scale web=1

    # Start a database
      $ heroku addons:add heroku-postgresql
      $ heroku pg:promote HEROKU_POSTGRESQL_PURPLE_URL

    # Enable backups
      $ heroku addons:add pgbackups:auto-month

    # Set up database
      $ heroku run run db-sync

Change admin password
---------------------

    $ ./run gen-admin

API
---

    $ curl http://feeds.app.com/sources.json

    $ curl http://feeds.app.com/feed.json

Restoring from backup
---------------------

    $ ./run backup-restore < backup.json
