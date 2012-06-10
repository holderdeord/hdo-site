module Pages
  class FrontPage < Page
    include HasMenu

    def load
      driver.navigate.to "http://localhost:3000"
    end

    def loaded?
      text =~ /bringer politikken til folket/i
    end
  end
end