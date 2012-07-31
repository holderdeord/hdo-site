module ApplicationHelper

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
    if what.include?(controller_name.to_sym) || what.include?("#{controller_name}_#{controller.action_name}".to_sym)
      'active'
    end
  end

  def spinner_tag
    str = '<div style="text-align: center;">' +
          image_tag('spinner.gif', id: 'spinner', alt: 'Loading...', style: 'display: none;') +
          '</div>'

    str.html_safe
  end

end
