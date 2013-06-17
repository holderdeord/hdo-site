namespace :export do
  task :reduce => :environment do
    raise "haha! no." unless Rails.env.development?

    default_password = 'hdo123'

    # remove all users
    User.destroy_all

    # create default user
    puts "creating development user admin@holderdeord.no / #{default_password}"

    User.create!(
      name: 'admin',
      email: "admin@holderdeord.no",
      password: default_password,
      password_confirmation: default_password,
      remember_me: false,
      role: 'superadmin'
    )

    puts "resetting representative passwords to #{default_password}"
    # reset all representative passwords
    Representative.where('confirmed_at IS NOT NULL').each do |rep|
      rep.password = default_password
      rep.password_confirmation = default_password
      rep.save!
    end

    puts "reducing issues"
    # keep (max) 10 issues for each status
    all_issues = Issue.all
    to_keep    = []

    all_issues.group_by { |e| e.status }.each do |_, issues|
      to_keep += issues.first(10)
    end

    (all_issues - to_keep).each(&:destroy)

    # TODO: reduce questions
  end

  file 'tmp/db.dev.sql' => :reduce do |t|
    sh "pg_dump --clean hdo_development > #{t.name}"
  end

  task :create => 'tmp/db.dev.sql'

  task :upload => :create do
    sh "scp tmp/db.dev.sql hdo@files.holderdeord.no:/webapps/files/dev/data/db.dev.sql"
  end
end