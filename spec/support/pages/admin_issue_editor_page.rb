module Pages
  class AdminIssueEditorPage < Page
    include HasMenu
    include SlowLoadableComponent

    def initialize(driver, url)
      super(driver)

      @url     = url
      @timeout = 5
    end

    def load
      driver.navigate.to @url
    end

    def loaded?
      driver.find_elements(id: 'issue-editor').any? && sections.size == 5
    end

    def intro_section
      section_for_key('intro').extend IntroSection
    end

    def propositions_section
      section_for_key('propositions').extend PropositionsSection
    end

    def promises_section
      section_for_key('promises').extend PromisesSection
    end

    def positions_section
      section_for_key('positions').extend PositionsSection
    end

    def party_comments_section
      section_for_key('party_comments').extend PartyCommentsSection
    end

    def sections
      driver.all(css: '[data-key]').map { |e| Section.new(self, e) }
    end

    def save
      driver.first(name: 'save').click
      wait_until {
        begin
          !spinner.displayed?
        rescue Selenium::WebDriver::Error::StaleElementReferenceError
          false
        end
      }

      error_messages.empty?
    end

    def show_issue
      driver.first(:css, 'a[rel=issue]').click
    end

    def error_messages
      driver.all(css: '.error-message').map(&:text).join
    end

    private

    def spinner
      driver.first(id: 'spinner')
    end

    def lock_version
      driver.first(id: 'issue_lock_version').attribute('value')
    end

    def section_for_key(key)
      sections.find { |e| e.key == key }
    end

    class Section
      include Waitable

      def initialize(page, element)
        @page    = page
        @element = element
      end

      def key
        @key ||= @element.attribute('data-key')
      end

      def set(key, value)
        @element.find_element(name: input_name_for(key)).send_keys(value)
      end

      def get(key)
        @element.find_element(name: input_name_for(key)).attribute('value')
      end

      def fill(data)
        data.each { |key, value| set(key, value) }
      end

      def open?
        @element.displayed?
      end

      def closed?
        !open?
      end

      def open
        return if open?

        toggle_element.click
        wait_until do
          others_closed = @page.sections.select { |e| e.key != key }.all?(&:closed?)
          others_closed && open?
        end
      end

      private

      def toggle_element
        @element.first(:xpath, "//*[@data-target='#collapse-#{key}']")
      end
    end

    module IntroSection
      def input_name_for(key)
        "issue[#{key}]"
      end
    end

    module PropositionsSection
      def use_first_proposition
        find
        select_first
        use_cart
      end

      def open?
        super && search_tab_link.displayed?
      end

      def find
        search_tab_link.click
      end

      def select_first
        wait_until { first_result.displayed? }
        first_result.click
      end

      def use_cart
        cart_element.first(:css, '[data-action=use]').click
      end

      def first_result
        @element.first(:css, '.search-result')
      end

      private

      def cart_element
        @element.first(:xpath, "//*[@class='cart' and @data-type='propositions']")
      end

      def search_tab_link
        @element.first(:css, '[href="#proposition-search-tab"]')
      end
    end

    module PromisesSection
      def use_first_promise
        find
        select_first
        use_cart
      end

      def open?
        super && search_tab_link.displayed?
      end

      def find
        search_tab_link.click
      end

      def select_first
        wait_until { first_result.displayed? }
        first_result.click
      end

      def use_cart
        cart_element.first(:css, '[data-action=use]').click
      end

      def first_result
        @element.first(:css, '.search-result')
      end

      private

      def cart_element
        @element.first(:xpath, "//*[@class='cart' and @data-type='promises']")
      end

      def search_tab_link
        @element.first(:css, '[href="#promise-search-tab"]')
      end
    end

    module PositionsSection
      def create(params)
        new_button.click

        Array(params[:parties]).each do |party_name|
          party_input.send_keys(party_name)
          party_input.send_keys(:return)
        end

        title_input.send_keys(params[:title]) if params[:title]
        desc_input.send_keys(params[:description]) if params[:description]
      end

      def new_button
        @element.first(:id, 'new-position')
      end

      def party_input
        @element.first(:css, 'input[value="Velg partier"]')
      end

      def title_input
        @element.first(:name, 'positions[-1][title]')
      end

      def desc_input
        @element.first(:name, 'positions[-1][description]')
      end
    end

    module PartyCommentsSection
      def create(params)
        new_button.click
        party_select.select_by(:text, params[:party]) if params[:party]
        comment_input.send_keys(params[:comment]) if params[:comment]
      end

      def new_button
        @element.first(:id, 'new-party-comment')
      end

      def party_select
        Selenium::WebDriver::Support::Select.new @element.first(:name, 'party_comments[-1][party_id]')
      end

      def comment_input
        @element.first(:name, 'party_comments[-1][body]')
      end
    end
  end
end
