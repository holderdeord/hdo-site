# encoding: utf-8

require 'spec_helper'

describe Position do
  it 'has a valid blueprint' do
    e = Position.make!
    e.should be_valid
  end

  it 'is invalid without parties' do
    e = Position.make parties: []

    e.should_not be_valid
  end

  it 'can uncapitalize the title' do
    e = Position.make(title: 'Ærlig TALT')

    e.downcased_title.should == 'ærlig TALT'
  end
end
