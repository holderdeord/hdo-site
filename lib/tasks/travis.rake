task :travis => %w[check db:drop db:migrate spec:small buster]

