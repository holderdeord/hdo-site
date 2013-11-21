# encoding: utf-8

require 'spec_helper'

describe PropositionConnectionDecorator do
  it 'has text for enacted state' do
    conn_enacted = PropositionConnection.make(vote: Vote.make!(:enacted => true))
    conn_refused = PropositionConnection.make(vote: Vote.make!(:enacted => false))

    enacted = PropositionConnectionDecorator.decorate(conn_enacted)
    refused = PropositionConnectionDecorator.decorate(conn_refused)

    I18n.with_locale :nb do
      enacted.enacted_text.should == 'Forslaget ble <strong>vedtatt</strong>.'
      refused.enacted_text.should == 'Forslaget ble <strong>ikke vedtatt</strong>.'
    end
  end
end
