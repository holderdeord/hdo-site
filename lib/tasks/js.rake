namespace :js do
  desc 'Run JS tests with Buster (requires node + buster)'
  task :test do
    # turn this into a buster-rails gem?

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

end