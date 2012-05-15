module Pages
  class FrontPage < Page
    include HasMenu

    def load
      driver.navigate.to "http://localhost:3000"
    end

    def loaded?
      driver.find_element(tag_name: 'body').text.include? 'er en politisk uavhengig organisasjon'
    end
  end
end