#!/bin/bash

set -e

echo "Checking bundle cache..."
echo

DEPLOY_HOST="deploy.holderdeord.no"
DEPLOY_PARAMS="repo_slug=${TRAVIS_REPO_SLUG}"

LOCAL_SHA=`openssl sha1 Gemfile.lock | cut -d'=' -f2 | tr -d ' '`
REMOTE_SHA=`curl --user ${HDO_DEPLOY_AUTH} -s "http://${DEPLOY_HOST}/travis/bundle/sha?${DEPLOY_PARAMS}"`

echo "  => old checksum: ${REMOTE_SHA}"
echo "  => new checksum: ${LOCAL_SHA}"
echo

if [[ "$LOCAL_SHA" = "$REMOTE_SHA" ]]; then
  echo "No changes to Gemfile.lock"
else
  echo "Gemfile.lock changed, uploading bundle"

  cd $HOME

  rm -f bundle.tgz
  tar cjf bundle.tgz .bundle

  curl -X PUT --user "${HDO_DEPLOY_AUTH}" "http://${DEPLOY_HOST}/travis/bundle?${DEPLOY_PARAMS}" --upload-file bundle.tgz
  curl -X PUT --user "${HDO_DEPLOY_AUTH}" "http://${DEPLOY_HOST}/travis/bundle/sha?${DEPLOY_PARAMS}" -d "$LOCAL_SHA"
fi
