#!/bin/bash

set -e

echo "Checking bundle cache..."
echo

PARAMS="repo_slug=${TRAVIS_REPO_SLUG}&branch=${TRAVIS_BRANCH}"

LOCAL_SHA=`openssl sha1 Gemfile.lock | cut -d'=' -f2 | tr -d ' '`
REMOTE_SHA=`curl --user ${HDO_DEPLOY_AUTH} -s "deploy.holderdeord.no/travis/bundle/sha?${PARAMS}"`

echo "  => old checksum: ${REMOTE_SHA}"
echo "  => new checksum: ${LOCAL_SHA}"
echo

if [[ "$LOCAL_SHA" = "$REMOTE_SHA" ]]; then
  echo "No changes to Gemfile.lock"
else
  echo "Gemfile.lock changed, uploading bundle"

  rm -f bundle.tgz
  tar cjf bundle.tgz ~/.bundle

  curl -X PUT --user "${HDO_DEPLOY_AUTH}" "http://deploy.holderdeord.no/travis/bundle?${PARAMS}" --upload-file bundle.tgz
  curl -X PUT --user "${HDO_DEPLOY_AUTH}" "http://deploy.holderdeord.no/travis/bundle/sha?${PARAMS}" -d "$LOCAL_SHA"
fi
