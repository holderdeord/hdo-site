#!/bin/sh

curl -o bundle.tgz http://files.holderdeord.no/travis/bundle.tgz
tar -xf bundle.tgz

bundle install --path .bundle --without=development

exit 0