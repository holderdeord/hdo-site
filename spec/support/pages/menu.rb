module Pages
  class Menu
    def initialize(driver)
      @driver = driver
    end

    def open_votes
      open_stortinget
      navbar_element.find_element(css: 'a[href="/votes"]').click
    end

    def search_for(query)
      search_input.send_keys(query)
    end

    def autocomplete_results
      autocomplete_dropdown.find_elements(tag_name: 'li').map { |e| AutocompleteResult.new(e.text) }
    rescue Selenium::WebDriver::Error::NoSuchElementError
      []
    end

    private

    def open_stortinget
      navbar_element.find_element(:css, 'a[href="#stortinget"]').click
    end

    def navbar_element
      @driver.find_element :class, 'navbar'
    end

    def search_input
      @driver.find_element(id: 'appendedInputButton')
    end

    def autocomplete_dropdown
      @driver.find_element(css: 'ul.typeahead')
    end

    class AutocompleteResult < Struct.new(:title)
    end
  end

  module HasMenu
    def menu
      Menu.new driver
    end
  end
end