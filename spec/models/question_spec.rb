require 'spec_helper'

describe Question do
  let(:q) { Question.make }

  it 'has a valid blueprint' do
    q.save!
  end

  it 'is invalid without a title' do
    q.title = nil
    q.should_not be_valid
  end

  it 'is invalid without a body' do
    q.body = nil
    q.should_not be_valid
  end

  it 'has a maximum title' do
    q.title = 'a' * 256
    q.should_not be_valid
  end

  it 'validates that sender is a valid email address' do
    q.sender = 'foo@bar.com'
    q.should be_valid

    q.sender = 'foo@bar'
    q.should_not be_valid
  end

  it 'knows if the question is awaiting control' do
    q.should be_awaiting_control
  end

end
