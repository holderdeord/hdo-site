namespace :js do
  desc 'Lint the JS files (requires node + jshint)'
  task :lint do
    files = Dir['{./app/assets,./spec}/javascripts/**/*.js'].reject { |e| e =~ %r[/(lib|twitter|conditional)/] }
    sh "jshint", *files
  end

  task :test => %w[jasmine:ci]

end
