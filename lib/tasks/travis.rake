task :travis => %w[
  check
  db:drop
  db:migrate
  tmp:create
  spec
  spec:coverage:ensure
]

