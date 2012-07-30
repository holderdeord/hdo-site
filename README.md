Prototype for holderdeord.no.

[![Build Status](https://secure.travis-ci.org/holderdeord/hdo-site.png)](http://travis-ci.org/holderdeord/hdo-site)

Development environment on Debian/Ubuntu
========================================

Install package dependencies and set up Ruby 1.9.3 with RVM.

    $ apt-get install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison libmysqlclient-dev imagemagick
    $ curl -L get.rvm.io | bash -s stable
    $ rvm install 1.9.3
    $ rvm use 1.9.3 --default
    $ ruby -v
    ruby 1.9.3p194 (2012-04-20 revision 35410) [x86_64-linux]

PS. For RVM to work properly with gnome-terminal, you have to set the 'Run command as login shell' checkbox on the "Title and Command" tab inside of gnome-terminal's Settings page.

Getting started:
================

    $ git clone git://github.com/holderdeord/hdo-site.git
    $ cd hdo-site
    $ [sudo] bundle install
    $ rake db:setup
    $ bundle exec rails server

Import data for development:
============================

* A subset from [data.stortinget.no](http://data.stortinget.no):

        $ script/import dev

* Import promises:

        $ bundle exec hdo-converter promises http://files.holderdeord.no/promises.csv | script/import xml -

Fetch representative images:
============================

These are not included in the repo by default.

    $ bundle exec rake images:fetch_representatives
