require 'spec_helper'

describe Answer do
  let(:a) { Answer.make }

  it 'has a valid blueprint' do
    a.save!
  end

  it 'is invalid without a body' do
    a.body = nil
    a.should_not be_valid
  end

  it 'is invalid without a representative' do
    a.representative = nil
    a.should_not be_valid
  end

  it 'is invalid qithout a question' do
    a.question = nil
    a.should_not be_valid
  end

end
