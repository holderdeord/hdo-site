require 'selenium-webdriver'
require 'loadable_component'

require_relative 'pages/page'
require_relative 'pages/menu'
require_relative 'pages/front_page'
require_relative 'pages/votes_page'

module BrowserSpecHelper
  extend self

  def driver
    $spec_driver ||= Selenium::WebDriver.for :firefox
  end

  def stop
    $spec_driver.quit if $spec_driver
  end

  def app_url
    "http://#{host}:#{port}"
  end

  def wait(timeout = 3)
    Selenium::WebDriver::Wait.new(timeout: timeout)
  end

  def front_page
    @front_page ||= Pages::FrontPage.new(driver, app_url)
  end

  def votes_page
    @votes_page ||= Pages::VotesPage.new(driver, front_page)
  end

  def host
    "127.0.0.1"
  end

  def start
    timeout = 15
    port_to_use = port()

    Thread.abort_on_exception = true

    $spec_app = Thread.new do
      Rack::Server.new(:app         => Hdo::Application,
                       :environment => Rails.env,
                       :server      => 'puma',
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
