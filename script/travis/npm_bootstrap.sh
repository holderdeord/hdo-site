#!/bin/bash

set -e

function setup () {
  npm install -g npm && npm install -g buster sinon autolint
}

setup || (sleep 5 && setup)