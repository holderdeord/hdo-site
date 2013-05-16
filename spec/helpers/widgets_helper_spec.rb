require 'spec_helper'

describe WidgetsHelper do
  let(:parties) { [Party.make!, Party.make!] }

  it "returns the party slug if there's only one party" do

    helper.slug_for_parties(parties).should == ''
    helper.slug_for_parties([parties.first]).should == parties.first.slug
  end

  it "returns links for the parties as a sentence" do
    I18n.with_locale :nb do
      links = helper.links_for_parties(parties)

      links.should include(%{href="/parties/#{parties.first.slug}"})
      links.should include(%{href="/parties/#{parties.last.slug}"})
    end
  end

  context 'promise links' do
    it 'links to the first main category' do
      category = Category.make!(main: true)
      promise = Promise.make!(categories: [category, Category.make!(main: false)])

      link = helper.link_for_promise(promise)
      link.should include "category_id=#{category.id}"
    end

    it 'falls back to the parent of the first' do
      main = Category.make!(main: true)
      child = Category.make!(main: false)

      main.children << child

      promise = Promise.make!(categories: [child])

      url = helper.link_for_promise(promise)
      url.should include "category_id=#{main.id}"
    end

    it 'includes party and parliament period' do
      url = helper.link_for_promise(Promise.make!)
      url.should include('party_slug=')
      url.should include('period=')
    end
  end
end
