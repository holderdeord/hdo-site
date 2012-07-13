task :travis => %w[db:drop db:migrate spec:small buster]

