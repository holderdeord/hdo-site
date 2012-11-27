# encoding: utf-8

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

  it 'has a translation for the status' do
    pc = PromiseConnection.make

    I18n.with_locale :nb do
      pc.status = 'for'
      pc.status_text.should == 'støtter saken'

      pc.status = 'against'
      pc.status_text.should == 'støtter ikke saken'

      pc.status = 'related'
      pc.status_text.should == 'relatert til saken'

      pc.status = 'unrelated'
      expect { pc.status_text }.to raise_error
    end
  end

end
