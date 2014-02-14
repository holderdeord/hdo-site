# encoding: utf-8

require 'spec_helper'

describe PropositionDecorator do
  let(:vote) { Vote.make!(time: 1.month.ago, :enacted => true) }
  let(:proposition) { Proposition.make!(:votes => [vote]) }
  let(:decorator) { proposition.decorate }

  it 'has a title' do
    proposition.description = 'foo'
    decorator.title.should == 'Foo'

    proposition.simple_description = 'æåø'
    decorator.title.should == 'Æåø'
  end

  it 'handles an empty description' do
    proposition.description = ''
    decorator.title.should == ''
  end

  it 'has a datestamp' do
    decorator.datestamp.should be_kind_of(String)
  end

  it 'has a timestamp' do
    decorator.timestamp.should be_kind_of(String)
  end

  it 'knows if the proposition was enacted' do
    decorator.should be_enacted
  end

  it 'has a body' do
    decorator.body.should be_nil
    proposition.simple_body = 'foo'
    decorator.body.should == '<p>foo</p>'
  end

  it 'has an original body' do
    decorator.original_body.should be_html_safe
  end

  it 'has a vote' do
    decorator.vote.should == vote
  end

  it 'has proposers' do
    party = Party.make!
    proposition.add_proposer party
    proposition.reload

    decorator.proposers.should == [party.name]
  end

  it 'has proposer links' do
    decorator.proposer_links.should be_html_safe
  end

  it 'has proposers, supporters and absentees' do
    decorator.proposers.should be_kind_of(Array)
    decorator.supporters.should be_kind_of(Array)
    decorator.absentees.should be_kind_of(Array)
  end

end