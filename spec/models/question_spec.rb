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

  it 'is invalid if the representative has opted out' do
    representative = Representative.make! opted_out: true
    q = Question.make representative: representative

    q.should_not be_valid
  end

  it 'is invalid if the representative does not have an email' do
    representative = Representative.make! email: nil
    q = Question.make representative: representative

    q.should_not be_valid
  end

  it 'is invalid if the representative is not attending' do
    representative = Representative.make! attending: false
    q = Question.make representative: representative

    q.should_not be_valid
  end

  it 'allows changing an existing question to non-attending representative' do
    representative = Representative.make! :attending
    q = Question.make! representative: representative
    q.should be_valid

    representative.update_attributes!(attending: false)

    q.reload.should be_valid
  end

  it 'is invalid without a body' do
    q.body = nil
    q.should_not be_valid
  end

  it 'is invalid if the body is too long' do
    q.body = 'a' * (Question::MAX_LENGTH + 1)
    q.should_not be_valid
  end

  it 'has a teaser' do
    q.body = 'a' * 105
    q.teaser.should == q.body.truncate(100)
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
    finally_rejected = Question.make!(status: 'finally_rejected')

    Question.approved.should == [approved]
    Question.pending.should == [pending]
    Question.rejected.should == [rejected]
    Question.finally_rejected.should == [finally_rejected]
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
    q1.should have_approved_answer

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

  it "doesn't allow answers from other representatives" do
    q = Question.make! status: 'approved'
    r = Representative.make! :confirmed
    a = Answer.make! representative: r
    q.answer = a
    q.should_not be_valid
  end

  it 'knows if a question is not from us' do
    a = Question.make!(from_email: 'foo@holderdeord.no')
    b = Question.make!(from_email: 'foo@example.com')

    Question.not_ours.should == [b]
  end

  it 'can have associated email events' do
    q = Question.make!
    q.email_events.create!(email_address: 'yona@test.hdo', email_type: 'test email')
    q.should be_valid
  end

  it "can add tags" do
    q.tag_list << 'some-tag'
    q.save

    q.tags.first.name.should == 'some-tag'
  end

  it "won't add the same tag twice" do
    q.tag_list << 'some-tag'
    q.tag_list << 'some-tag'
    q.save

    q.tags.size.should == 1
  end

  it "knows if status is changed to approved" do
    q = Question.make!(status: 'rejected')
    q.status = 'approved'
    q.status_changed_to?(:approved).should == true
  end

  it "sets a timestamp when status is changed to approved" do
    q = Question.make!(status: 'pending')
    q.save!
    q.approved_at.should be_nil

    q.status = 'approved'
    q.save!

    q.approved_at.should_not be_nil
  end
end
