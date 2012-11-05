require 'spec_helper'

module Hdo
  describe Instrumentation do

    let :payload do
      {
        :controller => "IssueController",
        :action     => "show",
        :status     => 200
      }
    end

    it 'sets up peformance instrumentation' do
      ActiveSupport::Notifications.should_receive(:subscribe).
                                   with('process_action.action_controller').
                                   and_yield('process_action.action_controller', 1.second.ago, Time.now, '1', payload)

      ActiveSupport::Notifications.should_receive(:subscribe).
                                   with('performance')
      Hdo::Instrumentation.init
    end

  end
end