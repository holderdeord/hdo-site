module PromisesHelper

  def default_url_options
    opts = {}
    opts[:period] = @period.external_id if @period

    opts
  end

  def period_filter_path_for(period)
    opts = default_url_options

    opts[:period]         = period.external_id
    opts[:category_id]    = @category.id if @category
    opts[:subcategory_id] = @subcategory.id if @subcategory
    opts[:promisor]       = [@promisor.id, @promisor.class.name].join(':') if @promisor

    promises_path opts
  end

  def category_path_for(category)
    opts = default_url_options

    opts[:category_id] = category.id
    opts[:promisor]    = [@promisor.id, @promisor.class.name].join(':') if @promisor

    promises_path opts
  end

  def subcategory_path_for(subcategory)
    if @category
      opts = default_url_options

      opts[:category_id]    = @category.id
      opts[:subcategory_id] = subcategory.id
      opts[:promisor]       = [@promisor.id, @promisor.class.name].join(':') if @promisor
    end

    promises_path opts
  end

  def promisor_path_for(promisor)
    opts = default_url_options

    opts[:promisor]       = [promisor.id, promisor.class.name].join(':')
    opts[:category_id]    = @category.id if @category
    opts[:subcategory_id] = @subcategory.id if @subcategory

    promises_path opts
  end

  def show_all_except_category
    opts = default_url_options

    opts[:promisor] = [@promisor.id, @promisor.class.name].join(':') if @promisor

    promises_path opts
  end

  def show_all_except_promisor
    opts = default_url_options

    opts[:category_id]    = @category.id if @category
    opts[:subcategory_id] = @subcategory.id if @subcategory

    promises_path opts
  end

  def show_all_except_subcategory
    opts = default_url_options

    opts[:category_id] = @category.id if @category
    opts[:promisor]    = [@promisor.id, @promisor.class.name].join(':') if @promisor

    promises_path opts
  end

  def show_all_promises_path
    opts = default_url_options

    opts[:promisor] = [@promisor.id, @promisor.class.name].join(':') if @promisor

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

  def show_promisor_as_selected(promisor)
    css_class = ''
    if @promisor
      css_class = promisor.name == @promisor.name ? 'active' : ''
    end

    css_class
  end

  def category_with_children?
    @category && @category.children.any?
  end

end