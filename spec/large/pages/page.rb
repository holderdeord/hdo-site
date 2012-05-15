module Pages
  class Page
    include LoadableComponent
    
    attr_reader :driver
   
    def initialize(driver)
      @driver = driver
    end
  end
end