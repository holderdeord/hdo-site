module Pages
  class AdminIssueEditorPage < Page
    include HasMenu
    include SlowLoadableComponent

    def initialize(driver, url)
      super(driver)
      @url = url
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
      section_for_key('promises').extend PositionsSection
    end

    def party_comments_section
      section_for_key('party_comments').extend PartyCommentsSection
    end

    def sections
      driver.all(css: '[data-key]').map { |e| Section.new(e) }
    end

    def save
      old_version = lock_version
      driver.find_element(name: 'save').click

      wait_until { !spinner.displayed? }

      error_messages.empty?
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

      def initialize(element)
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

      def open
        return if open?

        toggle_element.click
        wait_until { open? }
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
    end

    module PromisesSection
    end

    module PositionsSection
    end

    module PartyCommentsSection
    end
  end
end
