#!/bin/bash

RAILS_ENV="${RAILS_ENV:-development}"

psql "hdo_$RAILS_ENV" -t -X <<SQL
  COPY (
    SELECT 
      promises.id, 
      regexp_replace(body, E'[\\n\\r]+', ' ', 'g' ),
      source, 
      promisor_type, 
      concat(governments.name, parties.name) AS promisor, 
      parliament_periods.external_id AS period, 
      array_to_string(array_agg(categories.name), ';') AS category_names 
    FROM promises 
      INNER JOIN parliament_periods ON parliament_period_id = parliament_periods.id 
      LEFT JOIN governments ON governments.id = promisor_id AND promisor_type = 'Government' 
      LEFT JOIN parties ON parties.id = promisor_id AND promisor_type = 'Party' 
      LEFT JOIN categories_promises ON categories_promises.promise_id = promises.id 
      LEFT JOIN categories on categories_promises.category_id = categories.id 
    GROUP BY
      promises.id, 
      promisor, 
      period
  ) To STDOUT With CSV HEADER DELIMITER ',';
SQL
