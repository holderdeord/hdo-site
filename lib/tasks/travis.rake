task :travis => %w[check db:drop db:migrate spec:all]

