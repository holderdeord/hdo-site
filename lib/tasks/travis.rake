desc 'Run the full Travis build'
task :travis => %w[
  check
  db:create
  db:migrate
  tmp:create
  spec
  js:test
  js:lint
  spec:coverage:ensure
]

