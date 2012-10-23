[![Build Status](https://secure.travis-ci.org/holderdeord/hdo-site.png?branch=master)](http://travis-ci.org/holderdeord/hdo-site)

# IRC channel

Questions? Join us on [#holderdeord on irc.freenode.net](irc://irc.freenode.net/holderdeord)!

# Development environment

## ... on Debian/Ubuntu

Install package dependencies and set up Ruby 1.9.3 with RVM.


    $ sudo apt-get install \
        autoconf \
        automake \
        bison \
        build-essential \
        curl \
        git-core \
        imagemagick \
        libc6-dev \
        libpq-dev \
        libreadline6 \
        libreadline6-dev \
        libsqlite3-dev \
        libssl-dev \
        libtool \
        libxml2-dev \
        libxslt-dev \
        libyaml-dev \
        ncurses-dev \
        openssl \
        postgresql \
        zlib1g \
        zlib1g-dev

    $ curl -L get.rvm.io | bash -s stable --ruby
    $ ruby -v
    ruby 1.9.3p194 (2012-04-20 revision 35410) [x86_64-linux]

PS. For RVM to work properly with gnome-terminal, you have to tick the "Run command as login shell" checkbox on the "Title and Command" tab inside of gnome-terminal's Settings page.

### ElasticSearch

Follow the link to the latest stable release [here](http://www.elasticsearch.org/download/) and download the appropriate distribution. For apt, download the linked `.deb` and run:

    $ sudo dpkg -i elasticsearch.deb

### Database

To allow Rails to connect, edit /etc/postgresql/9.1/main/pg_hba.conf as root and change the line for Unix domain socket from "peer" to "trust":

     # "local" is for Unix domain socket connections only
    -local   all             all                                     peer
    +local   all             all                                     trust

Then restart the database:

    $ sudo su postgres -c "/etc/init.d/postgresql restart"

## ... on OS X

You'll need [XCode](https://developer.apple.com/xcode/) installed.

Install Ruby 1.9.3 through [RVM](http://rvm.io/):

    $ curl -L https://get.rvm.io | bash -s stable --ruby

Install dependencies through [Homebrew](http://mxcl.github.com/homebrew/):

_This list may be incomplete. Please add any missing libs you find._

    $ brew install git imagemagick elasticsearch

Follow the post-install instructions (`brew info elasticsearch`) on how to start ElasticSearch on login.

### Database

If you're on Lion or later, use [Postgres.app](http://postgresapp.com/):

* Download the app, drag it to /Applications and launch it.
* Set up your path to point to the command line tools as described [here](http://postgresapp.com/documentation).

Otherwise, use Homebrew to install PostgreSQL:

    $ brew install postgresql

Follow brew's post-install instructions for PostgreSQL. Typically you want to run the `initdb`
and the launchtl ("load on login") commands.

Note: If you're on OS X >= 10.7 and get a connection error when preparing the database, try these steps:

* Run `echo $PATH | tr ':' '\n'` and make sure /usr/local/bin comes before /usr/bin.
* Open a new shell and try there.
* Check [this post](http://www.iainlbc.com/2011/10/osx-lion-postgres-could-not-connect-to-database-postgres-after-homebrew-installation/).


# Preparing the database:

Create the "hdo" user with the [createuser command](http://www.postgresql.org/docs/9.1/interactive/app-createuser.html):

    $ sudo su - postgres # Only needed on Linux.
    $ createuser hdo --no-superuser --no-createrole --createdb

If you used [Postgres.app](http://postgresapp.com/), make sure you've set up the [command line tools](http://postgresapp.com/documentation) correctly. Otherwise you'll be using the older PostgreSQL version that ships with OS X >= 10.7.

# Starting the application:

    $ git clone git://github.com/holderdeord/hdo-site.git
    $ cd hdo-site
    $ gem install bundler
    $ [sudo] bundle install
    $ cp config/database.yml.example config/database.yml
    $ rake db:setup
    $ rails server

# Data

## Import data for development:

A subset from [data.stortinget.no](http://data.stortinget.no):

    $ rake import:dev

## Create ElasticSearch indeces

    $ rake search:reindex

## Set up images:

Run this task:

    $ rake images:all

This will download representative images and associate party logos with the imported parties. If you have broken images, try:

    $ rake images:representatives:reset images:all

## Data model

To see an entity-relationship diagram of the database:

    $ rake erd

    # or

    $ rake erd title="HDO Data Model"

This will generate `ERD.pdf`.

# Running specs:

To run all specs and buster.js tests:

    $ rake spec:all

To run all Ruby specs:

    $ rake spec

To run only JS tests:

    $ rake spec:js

You can also run specific specs, i.e. model, controller or request specs with e.g.:

    $ rake spec:models

Run affected specs automatically when files change:

    $ bundle exec guard

# JavaScript:

## Testing

We use [buster.js](http://busterjs.org/) for JavaScript testing.

To run the tests you need to have buster.js installed.
Buster.JS on the command-line requires Node 0.6.3 or newer and NPM.
Node 0.6.3 and newer comes with NPM bundled on most platforms.

Install buster and autolint:

    $ npm install -g buster autolint

To run the tests once:

    $ rake js:test

You can also run the buster server in the background and capture
 your local browser:

    $ buster server &

Then open [http://localhost:1111](localhost:1111) in your favorite browser.

To add more tests, update the config in spec/buster.js.

## Linting

    $ npm install -g autolint
    $ rake js:lint

or

    $ cd spec && autolint

# Deployment

Our own servers are set up with Puppet, using the code from the [hdo-puppet repo](http://github.com/holderdeord/hdo-puppet).

For test environments, deploying to [Heroku](http://www.heroku.com/) should work:

    $ [sudo] gem install heroku
    $ heroku login
    $ heroku create
    $ git push heroku master
    $ heroku run rake db:setup import:dev

One caveat: since Heroku doesn't allow writing to the file system, [Dragonfly won't work properly](http://markevans.github.com/dragonfly/file.Heroku.html).
