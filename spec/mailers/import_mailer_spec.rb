require "spec_helper"

describe ImportMailer do
  context 'votes today' do
    let(:mail) { ImportMailer.votes_today_email }
    let(:vote) { Vote.make!(created_at: 23.hours.ago) }
    let(:session_name) { '2013-2017' }

    context 'with votes' do
      before do
        Hdo::Stats::PropositionCounts.should_receive(:from_session).
          with(session_name).
          and_return(mock(pending_percentage: 1, pending: 1))

        ParliamentSession.should_receive(:current).
          and_return(mock(name: session_name))

        vote
      end

      it 'creates a multipart body' do
        mail.should be_multipart
      end

      it 'can fetch the raw HTML' do
        mail.parts.last.body.raw_source.should be_kind_of(String)
      end
    end

    context 'without votes' do
      it 'is not created if there are no votes' do
        ImportMailer.votes_today_email.to.should be_nil
      end
    end

  end
end
