namespace :js do
  desc 'Lint the JS files (requires node + autolint)'
  task :lint do
    Dir.chdir(Rails.root.join("spec")) do
      sh "autolint --once"
    end
  end

  task :copy_assets => :environment do
    mkdir_p Rails.root.join('tmp/buster')

    %w[require twitter/bootstrap jquery].each do |name|
      asset = Rails.application.assets.find_asset(name) or raise "couldn't find #{name.inspect}"
      dest = Rails.root.join("tmp/buster/#{name}.js")

      puts "writing #{asset.pathname} to #{dest}"

      mkdir_p dest.dirname
      asset.write_to(dest)
    end
  end

  task :setup => [:copy_assets, 'tmp/buster/require-conf.js']

  file 'tmp/buster/require-conf.js' do |t|
    gem_assets       = ["twitter/bootstrap"]
    requirejs_config = YAML.load_file(Rails.root.join("config/requirejs.yml"))

    config = {
      'paths' => {},
      'shim' => requirejs_config['shim']
    }

    config['paths']['hdo'] = 'app/assets/javascripts/hdo'
    requirejs_config['shim'].each_key do |key|
      tmp_path = "tmp/buster/#{key}"
      config['paths'][key] = tmp_path if File.exist?("#{tmp_path}.js")
    end

    File.open(t.name, "w") do |io|
      io << "var require = #{config.to_json}"
    end
  end

  desc 'Run JS tests with Buster (requires node + buster)'
  task :test => :setup do
    require 'childprocess'
    require 'selenium-webdriver'

    server = ChildProcess.build("buster-server")
    server.io.inherit!

    begin
      server.start
    rescue ChildProcess::LaunchError
      raise "unable to start buster, see http://busterjs.org/docs/getting-started/"
    end

    unless Selenium::WebDriver::SocketPoller.new('localhost', 1111, 10).connected?
      raise "timed out waiting for `buster server` to start"
    end

    drivers = []

    drivers << Selenium::WebDriver.for(:firefox)
    drivers << Selenium::WebDriver.for(:chrome) if Selenium::WebDriver::Platform.find_binary("chromedriver")

    drivers.each do |d|
      d.get "http://localhost:1111/capture"
    end

    begin
      sh "buster", "test"
    ensure
      drivers.each { |d| d.quit }
      server.stop
    end
  end

  desc "Install npm dependencies"
  task :install do
    deps = %w[buster autolint buster-amd]
    sh "npm", "-g", "install", *deps
    # TODO || (sleep 5 && npm install -g buster autolint)
  end

end