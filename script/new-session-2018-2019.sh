#!/bin/bash

set -e
set -x

bundle exec script/import parliament-sessions && \
  bundle exec script/import parliament-periods && \
  bundle exec script/import parties && \
  bundle exec script/import daily --period 2017-2021 --session 2017-2018 && \
  bundle exec script/import daily --period 2017-2021 --session 2018-2019 && \
  bundle exec rake images:party_logos && \
  bundle exec rake images:all && \
  bundle exec rake search:reindex && \
  bundle exec script/import agreement-stats && \
  bundle exec script/dump-promises.sh > /webapps/files/data/csv/promises.csv
