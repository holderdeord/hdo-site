module Pages
  class AdminLoginPage < Page
    include HasMenu

    def initialize(driver, url)
      super(driver)
      @url = url
    end

    def load
      driver.navigate.to @url
    end

    def loaded?
      email_field
      true
    rescue Selenium::WebDriver::Error::NoSuchElementError
      false
    end

    def login_as(user, pass)
      email_field.send_keys user
      password_field.send_keys pass
      login_button.click
    end

    private

    def email_field
      driver.find_element(id: 'user_email')
    end

    def password_field
      driver.find_element(id: 'user_password')
    end

    def login_button
      driver.find_element(name: 'commit')
    end
  end
end
