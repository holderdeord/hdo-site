#!/bin/bash

#
# Run this occasionally to update the bundle cache.
#
# Inspired by https://coderwall.com/p/x8exja

rm -rf bundle.tgz
tar cjf bundle.tgz .bundle

scp bundle.tgz hdo@files.holderdeord.no:/webapps/files/tmp/bundle.tgz