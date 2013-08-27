#!/bin/bash

set -e

function setup () {
  npm install -g npm && npm install -g buster sinon@1.6.0 autolint
}

setup || (sleep 5 && setup)