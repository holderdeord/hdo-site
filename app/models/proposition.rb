class Proposition < ActiveRecord::Base
  attr_accessible :description, :on_behalf_of, :body

  belongs_to :vote
  belongs_to :representative

  alias_method :delivered_by, :representative

  validates_presence_of :body, :description

  def plain_body
    Nokogiri::HTML.parse(body).inner_text.strip
  end

  def short_body
    str = plain_body
    str.size <= 200 ? str : "#{str[0,197]}..."
  end
end
