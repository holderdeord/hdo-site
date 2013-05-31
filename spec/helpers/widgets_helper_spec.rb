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
end
