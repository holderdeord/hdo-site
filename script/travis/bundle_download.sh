#!/bin/bash

PARAMS="repo_slug=${TRAVIS_REPO_SLUG}&branch=${TRAVIS_BRANCH}"

cd $HOME
curl --user "${HDO_DEPLOY_AUTH}" "http://deploy.holderdeord.no/travis/bundle?${PARAMS}" -o bundle.tgz
tar xf bundle.tgz || exit 0
