task :travis => %w[
  check
  db:drop
  db:migrate
  tmp:create
  spec
  js:test
  js:lint
  spec:coverage:ensure
]

