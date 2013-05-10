module PromisesHelper

  def default_url_options
    opts = {}
    opts[:period] = @period.external_id if @period

    opts
  end

  def period_filter_path_for(period)
    opts = default_url_options

    opts[:period] = period.external_id
    opts[:category_id] = @category.id if @category
    opts[:subcategory_id] = @subcategory.id if @subcategory
    opts[:party_slug] = @party.slug if @party

    promises_path opts
  end

  def category_path_for(category)
    opts = default_url_options

    opts[:category_id] = category.id
    opts[:party_slug] = @party.slug if @party

    promises_path opts
  end

  def subcategory_path_for(subcategory)
    if @category
      opts = default_url_options


      opts[:category_id] = @category.id
      opts[:subcategory_id] = subcategory.id
      opts[:party_slug] = @party.slug if @party
    end

    promises_path opts
  end

  def party_path_for(party)
    opts = default_url_options

    opts[:party_slug] = party.slug
    opts[:category_id] = @category.id if @category
    opts[:subcategory_id] = @subcategory.id if @subcategory

    promises_path opts
  end

  def show_all_except_category
    opts = default_url_options

    opts[:party_slug] = @party.slug if @party

    promises_path opts
  end

  def show_all_except_party
    opts = default_url_options

    opts[:category_id] = @category.id if @category
    opts[:subcategory_id] = @subcategory.id if @subcategory

    promises_path opts
  end

  def show_all_except_subcategory
    opts = default_url_options

    opts[:category_id] = @category.id if @category
    opts[:party_slug] = @party.slug if @party

    promises_path opts
  end

  def show_all_promises_path
    opts = default_url_options
    opts[:party_slug] = @party.slug if @party

    promises_path opts
  end

  def show_category_as_selected(category)
    if @category
      css_class = category.id == @category.id ? 'active' : ''
    end

    css_class
  end

  def show_subcategory_as_selected(subcategory)
    css_class = ''
    if @category
      css_class += subcategory.parent_id == @category.id ? '' : 'hidden'
    end
    if @subcategory
      css_class += subcategory.id == @subcategory.id ? 'active' : ''
    end

    css_class
  end

  def show_party_as_selected(party)
    css_class = ''
    if @party
      css_class = party.slug == @party.slug ? 'active' : ''
    end

    css_class
  end

  def category_with_children?
    @category && @category.children.any?
  end

end