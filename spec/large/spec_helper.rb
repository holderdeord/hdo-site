require 'selenium-webdriver'

require 'large/pages/page'
require 'large/pages/front_page'

if ENV['TRAVIS']
  ENV['DISPLAY'] = ":99"
end

module SpecHelper
  def driver
    $driver ||= Selenium::WebDriver.for :firefox
  end
  
  def app_url
    "http://localhost:3000"
  end
end

RSpec.configure do |config|
  config.include SpecHelper
  
  config.after(:suite) { $driver.close if $driver }
end
