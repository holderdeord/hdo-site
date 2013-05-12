require 'spec_helper'

describe Question do
  let(:q) { Question.make }

  it 'has a valid blueprint' do
    q.save!
  end

  it 'is invalid without a representative' do
    q.representative = nil
    q.should_not be_valid
  end

  it 'is invalid without a body' do
    q.body = nil
    q.should_not be_valid
  end

  it 'is invalid without name or email' do
    q.from_name = nil
    q.should_not be_valid

    q.from_email = nil
    q.should_not be_valid
  end

  it 'validates that from_email is a valid email address' do
    q.from_email = 'foo@bar.com'
    q.should be_valid

    q.from_email = 'foo@bar'
    q.should_not be_valid
  end

  it 'has status scopes' do
    pending = Question.make!(status: 'pending')
    approved = Question.make!(status: 'approved')
    rejected = Question.make!(status: 'rejected')

    Question.approved.should == [approved]
    Question.pending.should == [pending]
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

  it 'destroys dependent answers' do
    q.save!
    a = q.answers.create!(body: 'text', representative: Representative.make!)

    q.destroy

    expect { a.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'uses the full sender name if show_sender is true' do
    q = Question.make(from_name: 'Ola Nordmann', show_sender: true)
    q.from_display_name.should == 'Ola Nordmann'
  end

  it 'uses the shortened name if show_sender is false' do
    q = Question.make(from_name: 'Ola Nordmann', show_sender: false)
    q.from_display_name.should == 'O. N.'
  end
end
