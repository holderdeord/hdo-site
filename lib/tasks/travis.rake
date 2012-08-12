task :travis => %w[
  check
  db:drop
  db:migrate
  tmp:create
  spec:all
  spec:coverage:ensure
]

