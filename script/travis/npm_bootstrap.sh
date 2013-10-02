#!/bin/bash

set -e

function setup () {
  npm install -g autolint
}

setup || (sleep 5 && setup)