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
    'active' if what.include? controller_name.to_sym
  end

  def spinner_tag
    image_tag 'spinner.gif', id: 'spinner', alt: 'Loading...', style: 'display: none';
  end

end
