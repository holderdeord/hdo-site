require "spec_helper"

describe ImportMailer do
  context 'votes today' do
    let(:mail) { ImportMailer.votes_today_email }
    let(:vote) { Vote.make!(:with_proposition) }

    context 'with votes' do
      before do
        vote.created_at = 23.hours.ago
      end

      after do
        vote.destroy
      end

      it 'creates a multipart body' do
        mail.should be_multipart
      end

      it 'has an HTML body' do
        source = mail.parts.last.body.raw_source

        source.should be_kind_of(String)
        source.should_not be_empty
      end

      it 'has a text body' do
        source = mail.parts.first.body.raw_source

        source.should be_kind_of(String)
        source.should_not be_empty
      end
    end

    context 'without votes' do
      it 'is not created if there are no votes' do
        ImportMailer.votes_today_email.to.should be_nil
      end
    end

  end
end
