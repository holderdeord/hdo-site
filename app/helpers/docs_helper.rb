module DocsHelper
  def type_name(klass)
    klass.name.split("::").last.downcase
  end
end
