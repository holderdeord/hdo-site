#!/bin/bash

set -x

ruby -v
dpkg -s elasticsearch | grep --color=never Version
node --version
npm --version
