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

  it 'is invalid if the answer is invalid' do
    q.status = 'approved'
    q.save!

    q.create_answer!(representative: q.representative, body: 'foo')
    q.should be_valid

    q.answer.body = nil
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

  it 'destroys dependent answer' do
    q.status = 'approved'
    q.save!
    a = q.create_answer!(representative: q.representative, body: 'text')

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

  it 'finds answered questions' do
    q1 = Question.make!
    q2 = Question.make!
    q3 = Question.make!

    [q1, q2, q3].map(&:approve!)

    Answer.make!(question: q1, status: 'approved')
    Answer.make!(question: q2, status: 'pending')

    Question.answered.should == [q1, q2]

    q1.should be_answered
    q2.should be_answered
    q3.should_not be_answered
  end

  it 'finds unanswered questions' do
    q1 = Question.make!
    q2 = Question.make!

    [q1, q2].map(&:approve!)
    Answer.make!(question: q1)

    Question.unanswered.should == [q2]
  end

  it 'doesnt allow answers from other representatives' do
    q = Question.make! status: 'approved'
    r = Representative.make! :confirmed
    a = Answer.make! representative: r
    q.answer = a
    q.should_not be_valid
  end

  it 'knows if a question is from us' do
    a = Question.make!(from_email: 'foo@holderdeord.no')
    b = Question.make!(from_email: 'foo@example.com')

    Question.not_ours.should == [b]
  end

  it 'can have associated email events' do
    q = Question.make!
    q.email_events.create!(email_address: 'yona@test.hdo', email_type: 'test email')
    q.should be_valid
  end
end
