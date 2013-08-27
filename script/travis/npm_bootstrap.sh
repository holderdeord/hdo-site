#!/bin/bash

set -e

npm cache clear
npm install -g buster sinon@1.6.0 autolint || (sleep 5 && npm install -g buster sinon@1.6.0 autolint)