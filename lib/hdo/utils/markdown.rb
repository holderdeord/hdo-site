module Hdo
  module Utils
    module Markdown
      module_function

      def render(text)
        @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML)
        @markdown.render(text)
      end

    end
  end
end