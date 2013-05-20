require 'spec_helper'

describe Answer do
  let(:a) { Answer.make }

  it 'has a valid blueprint' do
    a.save!
  end

  it 'is invalid without a body' do
    a.body = nil
    a.should_not be_valid
  end

  it 'is invalid without a representative' do
    a.representative = nil
    a.should_not be_valid
  end

  it 'is invalid qithout a question' do
    a.question = nil
    a.should_not be_valid
  end

  it 'is invalid if the question is not approved' do
    a.question.reject!
    a.should_not be_valid

    a.question.approve!
    a.should be_valid
  end

  it "returns the representative's party when the answer was posted" do
    party_a = Party.make!
    party_b = Party.make!

    rep = Representative.make!

    rep.party_memberships.create!(party: party_a, start_date: 1.year.ago, end_date: 1.month.ago)
    rep.party_memberships.create!(party: party_b, start_date: 29.days.ago, end_date: nil)

    a = Answer.make(representative: rep)
    a.created_at = 2.months.ago

    a.party.should == party_a
    a.created_at = Time.now

    a.party.should == party_b
  end

  it 'touches the corresponding question' do
    q = Question.make!(status: 'approved')
    old_time = q.updated_at

    Answer.make!(question: q)
    q.updated_at.should > old_time
  end
end
