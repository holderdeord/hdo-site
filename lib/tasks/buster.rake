
task :buster do
  # turn this into a buster-rails gem?

  require 'childprocess'
  require 'selenium-webdriver'

  server = ChildProcess.build("buster-server")
  server.io.inherit!

  begin
    server.start
  rescue ChildProcess::LaunchError
    raise "could not find buster, see http://busterjs.org/docs/getting-started/"
  end

  unless Selenium::WebDriver::SocketPoller.new('localhost', 1111, 10).connected?
    raise "unable to start buster server"
  end

  d = Selenium::WebDriver.for :firefox
  d.get "http://localhost:1111/capture"

  begin
    sh "buster", "test"
  ensure
    d.quit
    server.stop
  end

end
