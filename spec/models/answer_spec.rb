require 'spec_helper'

describe Answer do
  let(:q) { Question.make! }
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

  it 'disallows multiple answers from the same representative' do
    rep = Representative.make!
    q   = Question.make!
    q2  = Question.make!

    q.answers.create!(body: 'a', representative: rep)
    q.answers.create(body: 'b', representative: rep).should_not be_valid

    # allowed to answer other Qs
    q2.answers.create!(body: 'a', representative: rep)
  end

end
