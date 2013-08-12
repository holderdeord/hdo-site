# encoding: utf-8

require 'spec_helper'

describe VoteConnectionDecorator do
  it 'has text for matches state' do
    issue        = Issue.make!(:title => 'Øke ditt og datt')
    matching     = VoteConnectionDecorator.decorate(VoteConnection.make!(matches: true,  issue: issue), context: issue)
    non_matching = VoteConnectionDecorator.decorate(VoteConnection.make!(matches: false, issue: issue), context: issue)

    I18n.with_locale :nb do
      matching.matches_text.should     == 'Å stemme for dette forslaget er <strong>i tråd med</strong> å øke ditt og datt.'
      non_matching.matches_text.should == 'Å stemme for dette forslaget er <strong>ikke i tråd med</strong> å øke ditt og datt.'
    end
  end

  it 'has text for enacted state' do
    conn_enacted = VoteConnection.make(vote: Vote.make!(:enacted => true))
    conn_refused = VoteConnection.make(vote: Vote.make!(:enacted => false))

    enacted = VoteConnectionDecorator.decorate(conn_enacted)
    refused = VoteConnectionDecorator.decorate(conn_refused)

    I18n.with_locale :nb do
      enacted.enacted_text.should == 'Forslaget ble <strong>vedtatt</strong>.'
      refused.enacted_text.should == 'Forslaget ble <strong>ikke vedtatt</strong>.'
    end
  end
end
