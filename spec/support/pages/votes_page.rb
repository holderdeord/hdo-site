module Pages
  class VotesPage < Page
    include SlowLoadableComponent

    def initialize(driver, parent)
      super(driver)
      @parent = parent
      @timeout = 3
    end

    def load
      @parent.get.menu.open_votes
    end

    def loaded?
      current_path == expected_path
    end

    def unable_to_load_message
      "expected path #{expected_path.inspect}, got #{current_path.inspect}\n#{text}"
    end

    def expected_path
      "/votes"
    end

    def first_vote
      Vote.new driver.find_element(xpath: "//table[@id='votes']/tbody/tr")
    end

    def vote_count
      text = vote_count_element.text
      text[/\d+/].to_i
    end

    private

    def vote_count_element
      driver.find_element(id: 'app.counts.vote')
    end

    class Vote
      def initialize(element)
        @element = element
      end

      def for
        @element.find_element(:css => '.vote-for').text
      end

      def against
        @element.find_element(:css => '.vote-against').text
      end

      def absent
        @element.find_element(:css => '.vote-absent').text
      end
    end

  end
end