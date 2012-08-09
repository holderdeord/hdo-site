module DocsHelper
  def base_kind(type)
    type.kind.split("#", 2).last
  end
end
