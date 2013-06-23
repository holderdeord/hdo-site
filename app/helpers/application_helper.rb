module ApplicationHelper

  def header_class
    header_class = []

    if content_for?(:jumbotron)
      header_class << 'jumbotron'
    end

    header_class.join ' '
  end

  def header_style
    if request.path == "/"
      "background-image:url('#{asset_path("jumbotron_frontpage.jpg")}')"
    end
  end

  def obscure_email(email)
    return nil if email.nil?

    lower = ('a'..'z').to_a
    upper = ('A'..'Z').to_a

    email.split('').map { |char|
      output = lower.index(char) + 97 if lower.include?(char)
      output = upper.index(char) + 65 if upper.include?(char)
      output ? "&##{output};" : (char == '@' ? '&#0064;' : char)
    }.join.html_safe
  end

  def active_status_for(*what)
    what = what.map(&:to_s)
    if what.include?(controller_path) || what.include?("#{controller_path}_#{controller.action_name}")
      'active'
    end
  end

  def spinner_tag(opts = nil)
    style = {style: 'text-align: center;'}
    style.merge!(opts) if opts

    content_tag 'div', opts do
      image_tag('spinner.gif', id: 'spinner', alt: 'Loading...', style: 'display: none;')
    end
  end

  # http://daniel.collectiveidea.com/blog/2007/07/10/a-prettier-truncate-helper/
  def awesome_truncate(text, length = 30, truncate_string = "...")
    return if text.nil?
    l = length - truncate_string.chars.to_a.size
    text.chars.to_a.size > length ? text[/\A.{#{l}}\w*\;?/m][/.*[\w\;]/m] + truncate_string : text
  rescue => ex
    logger.error "awesome_truncate: #{ex.message}"
    text
  end

  def gravatar_url(email, opts = {})
    default = opts[:fallback] == 'blank' ? 'blank' : asset_url("representatives/fallback_avatar.png")
    "//gravatar.com/avatar/#{Digest::MD5.hexdigest email}?s=300&d=#{URI.encode default}"
  end

  def metadata
    @metadata ||= {
      type: 'website',
      title: page_title,
      description: t('app.opengraph.description'),
      url: "http://#{request.host}#{request.fullpath}"
    }
  end

  def page_title(page_title = nil)
    if page_title
      @page_title = page_title
    end

    @page_title || t('app.title')
  end

  def markdown(text)
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    @markdown.render(text)
  end

  def asset_url(asset)
    "#{request.protocol}#{request.host_with_port}#{asset_path(asset)}"
  end
end
