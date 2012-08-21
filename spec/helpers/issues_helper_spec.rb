require 'spec_helper'

describe IssuesHelper do
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
      [ "2.0", "2",   nil        ],
      [ "4.0", "4",   nil        ]
    ]

    expected.should == actual
  end
end