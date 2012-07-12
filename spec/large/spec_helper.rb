require 'selenium-webdriver'

require 'large/pages/page'
require 'large/pages/menu'
require 'large/pages/front_page'
require 'large/pages/votes_page'

if ENV['TRAVIS']
  ENV['DISPLAY'] = ":99"
end

Thread.abort_on_exception = true

module SpecHelper
  extend self

  def driver
    $spec_driver ||= (
      driver = Selenium::WebDriver.for :firefox
      driver.manage.window.maximize

      driver
    )
  end

  def quit_driver
    $spec_driver.quit if $spec_driver
  end

  def app_url
    "http://#{host}:#{port}"
  end

  def front_page
    @front_page ||= Pages::FrontPage.new(driver)
  end

  def votes_page
    @votes_page ||= Pages::VotesPage.new(driver, front_page)
  end

  def host
    "127.0.0.1"
  end

  def launch_app
    timeout = 15
    port_to_use = port()

    $spec_app = Thread.new do
      Rack::Server.new(:app         => Hdo::Application,
                       :environment => Rails.env,
                       :Port        => port_to_use).start
    end

    sp = Selenium::WebDriver::SocketPoller.new(host, port, timeout)
    unless sp.connected?
      raise "could not launch app in #{timeout} seconds"
    end
  end

  def port
    $spec_port ||= Selenium::WebDriver::PortProber.above(3000)
  end
end

RSpec.configure do |config|
  config.include SpecHelper

  config.use_transactional_fixtures = false

  config.before(:suite) { SpecHelper.launch_app }
  config.after(:suite) do
    SpecHelper.quit_driver
  end
end
