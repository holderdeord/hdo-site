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

  it 'is valid without name or email' do
    q.from_name = nil
    q.should be_valid

    q.from_email = nil
    q.should be_valid
  end

  it 'validates that from_email is a valid email address' do
    q.from_email = 'foo@bar.com'
    q.should be_valid

    q.from_email = 'foo@bar'
    q.should_not be_valid
  end

  it 'validates statuses' do
    q.status = 'pending'
    q.should be_valid
    q.should be_pending

    q.status = 'approved'
    q.should be_valid
    q.should be_approved

    q.status = 'rejected'
    q.should be_valid
    q.should be_rejected

    q.status = 'foo'
    q.should_not be_valid
  end

  it 'has status scopes' do
    pending = Question.make!(status: 'pending')
    approved = Question.make!(status: 'approved')
    rejected = Question.make!(status: 'rejected')

    Question.approved.should == [approved]
  end

  it 'has a status text' do
    I18n.with_locale(:nb) do
      q.status = 'pending'
      q.status_text.should == 'Avventer kontroll'

      q.status = 'approved'
      q.status_text.should == 'Godkjent'

      q.status = 'rejected'
      q.status_text.should == 'Avvist'
    end
  end
end
