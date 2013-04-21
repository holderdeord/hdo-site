module PromisesHelper

  def category_path_for(category)
    opts = {
      category_id: category.id,
      anchor: 'top'
    }

    opts[:party_slug] = @party.slug if @party

    promises_path opts
  end

  def subcategory_path_for(subcategory)
    if @category
      opts = {
        category_id: @category.id,
        subcategory_id: subcategory.id,
        anchor: 'top'
      }
      
      opts[:party_slug] = @party.slug if @party
    end

    promises_path opts
  end

  def party_path_for(party)
    opts = {
        anchor: 'top',
        party_slug: party.slug
    }

    opts[:category_id] = @category.id if @category
    opts[:subcategory_id] = @subcategory.id if @subcategory

    promises_path opts
  end

  def show_all_except_category
    opts = {}

    opts[:party_slug] = @party.slug if @party

    promises_path opts
  end

  def show_all_except_party
    opts = {}

    opts[:category_id] = @category.id if @category
    opts[:subcategory_id] = @subcategory.id if @subcategory

    promises_path opts
  end

  def show_all_except_subcategory
    opts = {}

    opts[:category_id] = @category.id if @category
    opts[:party_slug] = @party.slug if @party

    promises_path opts
  end

  def show_all_promises_path
    opts = {}
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
    if @category
      css_class += subcategory.parent_id == @category.id ? '' : 'hidden'
    end
    if @subcategory
      css_class = subcategory.id == @subcategory.id ? 'active' : ''
    end

    css_class
  end

  def show_party_as_selected(party)
    if @party
      css_class = party.slug == @party.slug ? 'active' : ''
    end

    css_class
  end

end