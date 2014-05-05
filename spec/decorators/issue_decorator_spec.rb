require 'spec_helper'

describe IssueDecorator do
  let(:model) { Issue.make!(promise_connections: [PromiseConnection.make!]) }
  let(:issue) { model.decorate }

  it 'has periods' do
    issue.periods.first.should be_kind_of(IssueDecorator::Period)
  end

  it 'has knows when it was last updated' do
    issue.updated_at.should be_kind_of(String)
    issue.time_since_updated.should be_kind_of(String)
  end
end