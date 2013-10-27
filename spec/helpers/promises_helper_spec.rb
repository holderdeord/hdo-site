require 'spec_helper'

describe PromisesHelper do

  it 'returns the category filter path' do
    helper.category_path_for(stub(id: 1)).should include "/promises?category_id=1"
  end

  it 'returns the category + promise filter path' do
    @promisor = stub(id: 5, class: stub(name: 'Party'))
    helper.category_path_for(stub(id: 1)).should include "/promises?category_id=1&promisor=5%3AParty"
  end

  it 'returns the category + subcategory filter path' do
    @category = stub(id: 1)

    helper.subcategory_path_for(stub(id: 2)).should include "/promises?category_id=1&subcategory_id=2"
  end

  it 'returns the category + subcategory + party filter path' do
    @category = stub(id: 1)
    @promisor = stub(id: 5, class: stub(name: 'Party'))

    helper.subcategory_path_for(stub(id: 2)).should include "/promises?category_id=1&promisor=5%3AParty&subcategory_id=2"
  end

  it 'returns the promisor filter path' do
    promisor = stub(id: 5, class: stub(name: 'Party'))

    helper.promisor_path_for(promisor).should include "/promises?promisor=5%3AParty"
  end

  it 'returns the promisor + category filter path' do
    @category = stub(id: 1)
    promisor  = stub(id: 5, class: stub(name: 'Party'))

    helper.promisor_path_for(promisor).should include "/promises?category_id=1&promisor=5%3AParty"
  end

  it 'returns the promisor + category + subcategory filter path' do
    @category    = stub(id: 1)
    @subcategory = stub(id: 2)

    promisor = stub(id: 5, class: stub(name: 'Party'))

    helper.promisor_path_for(promisor).should include "/promises?category_id=1&promisor=5%3AParty&subcategory_id=2"
  end

  it 'returns the promisor - category filter path' do
    @promisor = stub(id: 5, class: stub(name: 'Party'))
    @category = stub(id: 1)

    helper.show_all_except_category.should == "/promises?promisor=5%3AParty"
  end

  it 'returns the promisor + category - subcategory filter path' do
    @promisor    = stub(id: 5, class: stub(name: 'Party'))
    @category    = stub(id: 1)
    @subcategory = stub(id: 2)

    helper.show_all_except_subcategory.should == "/promises?category_id=1&promisor=5%3AParty"
  end

  it 'returns promisor + category + period path' do
    @period   = stub(external_id: '2009-2013')
    @promisor = stub(id: 5, class: stub(name: 'Party'))
    @category = stub(id: 1)

    helper.promisor_path_for(@promisor).should include "/promises?category_id=1&period=2009-2013&promisor=5%3AParty"
  end

  it 'returns the period filter path' do
    period = stub(external_id: '2009-2013')

    helper.period_filter_path_for(period).should include('/promises?period=2009-2013')
  end

end
