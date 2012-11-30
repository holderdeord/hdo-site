require 'spec_helper'

describe VoteConnectionDecorator do
  let(:view) { VoteConnectionDecorator.new(VoteConnection.make!) }

  it 'has text for matches state' do
    view.matches_text.should be_kind_of(String)
  end

  it 'has text for enacted state' do
    view.enacted_text.should be_kind_of(String)
  end
end
