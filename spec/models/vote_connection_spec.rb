require 'spec_helper'

describe VoteConnection do
  let(:vote_connection) { VoteConnection.make! }

  it 'should have a valid blueprint' do
    vote_connection.should be_valid
  end

  it 'should be invalid without a vote' do
    VoteConnection.make(:vote => nil).should be_invalid
  end

  it 'should be invalid without a issue' do
    VoteConnection.make(:issue => nil).should be_invalid
  end

  it 'validates the weight values' do
    conn = VoteConnection.make

    conn.weight = 0
    conn.should be_valid
    conn.weight_text.should be_kind_of(String)

    conn.weight = 0.5
    conn.should be_valid
    conn.weight_text.should be_kind_of(String)

    conn.weight = 1
    conn.should be_valid
    conn.weight_text.should be_kind_of(String)

    conn.weight = 2
    conn.should be_invalid
    expect { conn.weight_text }.to raise_error

    conn.weight = 3
    conn.should be_invalid
    expect { conn.weight_text }.to raise_error

    conn.weight = 4
    conn.should be_invalid
    expect { conn.weight_text }.to raise_error

    conn.weight = 100
    conn.should be_invalid
    expect { conn.weight_text }.to raise_error
  end
end
