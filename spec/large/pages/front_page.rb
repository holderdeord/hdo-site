module Pages
  class FrontPage < Page
    
    def get
      driver.navigate.to "http://localhost:3000"
    end
    
    def loaded?
      driver.find_element(tag_name: 'body').text.include? 'er en politisk uavhengig organisasjon'
    end
  end
end