task :travis => %w[
  check
  db:drop
  db:migrate
  tmp:create
  spec:all
  js:test
  js:lint
  spec:coverage:ensure
]

