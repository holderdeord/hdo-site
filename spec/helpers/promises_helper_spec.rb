require 'spec_helper'

describe PromisesHelper do
  it 'returns the category filter path' do
    helper.category_path_for(stub(id: 1)).should include "/promises?category_id=1"
  end

  it 'returns the category + promise filter path' do
    @party = mock(slug: 'krf')
    helper.category_path_for(stub(id: 1)).should include "/promises?category_id=1&party_slug=krf"
  end

  it 'returns the category + subcategory filter path' do
    @category = stub(id: 1)

    helper.subcategory_path_for(stub(id: 2)).should include "/promises?category_id=1&subcategory_id=2"
  end

  it 'returns the category + subcategory + party filter path' do
    @category = stub(id: 1)
    @party = stub(slug: 'krf')

    helper.subcategory_path_for(stub(id: 2)).should include "/promises?category_id=1&party_slug=krf&subcategory_id=2"
  end

  it 'returns the party filter path' do
    helper.party_path_for(stub(slug: 'krf')).should include "/promises?party_slug=krf"
  end

  it 'returns the party + category filter path' do
    @category = stub(id: 1)
    helper.party_path_for(stub(slug: 'krf')).should include "/promises?category_id=1&party_slug=krf"
  end

  it 'returns the party + category + subcategory filter path' do
    @category = stub(id: 1)
    @subcategory = stub(id: 2)

    helper.party_path_for(stub(slug: 'krf')).should include "/promises?category_id=1&party_slug=krf&subcategory_id=2"
  end

  it 'returns the party - category filter path' do
    @party    = stub(slug: 'krf')
    @category = stub(id: 1)

    helper.show_all_except_category.should == '/promises?party_slug=krf'
  end

  it 'returns the party + category - subcategory filter path' do
    @party       = stub(slug: 'krf')
    @category    = stub(id: 1)
    @subcategory = stub(id: 2)

    helper.show_all_except_subcategory.should == '/promises?category_id=1&party_slug=krf'
  end

end
