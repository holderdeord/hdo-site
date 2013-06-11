require "spec_helper"

describe ImportMailer do
  context 'votes today' do
    let(:mail) { ImportMailer.votes_today_email }
    let(:vote) { Vote.make!(created_at: 23.hours.ago) }

    it 'creates a multipart body' do
      vote
      mail.should be_multipart
    end

    it 'is not created if there are no votes' do
      ImportMailer.votes_today_email.to.should be_nil
    end

    it 'can fetch the raw HTML' do
      vote
      mail.parts.last.body.raw_source.should be_kind_of(String)
    end
  end
end
