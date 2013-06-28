require 'spec_helper'

describe Admin::IssuesHelper do
  it 'should create options for the weight dropdown' do
    conn = VoteConnection.make!(:weight => 0.5)

    doc = Nokogiri::HTML.parse(weight_options_for(conn))

    actual = doc.css("option").map do |node|
      [ node['value'], node.text, node['selected'] ]
    end

    expected = [
      [ "0.0", "0",   nil        ],
      [ "0.5", "0.5", 'selected' ],
      [ "1.0", "1",   nil        ],
    ]

    expected.should == actual
  end

  it 'should create options for proposition types' do
    opts = proposition_type_options_for(VoteConnection.make!(proposition_type: 'parliamentary_report'))

    opts.should be_kind_of(String)
    opts.should_not be_empty
  end
end
