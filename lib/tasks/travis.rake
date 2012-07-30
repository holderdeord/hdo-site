task :travis => %w[check db:drop db:migrate spec:small spec:large buster]

