#!/bin/bash

set -e

function setup () {
  npm install -g jshint
}

# retry once if npm fails
setup || (sleep 5 && setup)
