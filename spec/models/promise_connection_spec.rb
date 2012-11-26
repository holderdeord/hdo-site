require 'spec_helper'

describe PromiseConnection do
  it 'should have a valid blueprint' do
    PromiseConnection.make.should be_valid
  end

  it 'should be invalid without a promise' do
    PromiseConnection.make(promise: nil).should be_invalid
  end

  it 'should be invalid without a issue' do
    PromiseConnection.make(issue: nil).should be_invalid
  end

  it 'validates the status values' do
    pc = PromiseConnection.make

    pc.status = 'for'
    pc.should be_valid

    pc.status = 'against'
    pc.should be_valid

    pc.status = 'related'
    pc.should be_valid

    pc.status = 'unrelated'
    pc.should_not be_valid
  end

end
