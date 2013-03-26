ActsAsTaggableOn.remove_unused_tags = true
ActsAsTaggableOn.force_lowercase    = true

ActsAsTaggableOn::Tag.class_eval do
  def slug
    name.gsub(/\s+/, '-').gsub(/[^\w-]/, '').downcase
  end
end