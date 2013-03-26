#!/bin/bash

if [[ -n "${HDO_DEPLOY_AUTH}" ]]; then
  cd $HOME
  curl --user "${HDO_DEPLOY_AUTH}" "http://deploy.holderdeord.no/travis/bundle?repo_slug=${TRAVIS_REPO_SLUG}" -o bundle.tgz
  tar xf bundle.tgz || exit 0
else
  echo "HDO_DEPLOY_AUTH not available, not downloading bundle"
fi
