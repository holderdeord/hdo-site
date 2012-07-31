unless ENV['RAILS_ENV'] == "production"
  namespace :spec do
    desc 'Run small specs (lib, model, controller)'
    task :small => %w[spec:lib spec:models spec:controllers]

    desc 'Run large specs (requests).'
    task :large => %w[spec:requests]

    desc 'Run all specs (including buster).'
    task :all   => %w[spec spec:js]

    desc 'Run buster specs'
    task :js => :buster
  end
end
