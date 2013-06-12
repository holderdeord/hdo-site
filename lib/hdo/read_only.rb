module Hdo
  module ReadOnly
    def require_edit
      if AppConfig.read_only
        render_read_only_page
      end
    end

    def render_read_only_page
      render file: 'public/read_only', formats: [:html], layout: false, status: 307
    end
  end
end