require 'spec_helper'

describe QuestionDecorator do
  let(:question) { Question.make!(representative: Representative.make!(:confirmed)) }
  let(:decorator) { question.decorate }

  it "has the representative's avatar" do
    decorator.representative_avatar.should_not be_nil
  end

  it "has the representative's name" do
    decorator.representative_name.should == question.representative.name
  end

  it "has the representative's party logo" do
    decorator.party_logo.should_not be_nil
  end

  it "has the representative's party name" do
    decorator.party_name.should == question.representative.party_at(question.created_at).name
  end

  it "has the representative's district name" do
    decorator.district_name.should == question.representative.district.name
  end

  it "has a status description" do
    decorator.status_description.should be_kind_of(String)
  end

  it "has a teaser" do
    decorator.teaser.should be_kind_of(String)
  end

  it "knows if the question has an approved answered" do
    decorator.should_not have_approved_answer
  end
end