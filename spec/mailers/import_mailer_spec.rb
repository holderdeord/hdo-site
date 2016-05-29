require "spec_helper"

shared_examples 'mail with body' do
  it 'creates a multipart body' do
    expect(mail).to be_multipart
  end

  it 'has an HTML body' do
    source = mail.parts.last.body.raw_source

    expect(source).to be_kind_of(String)
    expect(source).to_not be_empty
  end

  it 'has a text body' do
    source = mail.parts.first.body.raw_source

    expect(source).to be_kind_of(String)
    expect(source).to_not be_empty
  end
end

describe ImportMailer do
  let(:mail) { ImportMailer.votes_today_email }

  context 'votes today' do
    let(:vote) { Vote.make!(:with_proposition) }
    let(:parliament_issue) { ParliamentIssue.make!(:status => 'mottatt') }

    context 'with votes' do
      before do
        vote.created_at = 23.hours.ago
      end

      after do
        vote.destroy
      end

      it_behaves_like 'mail with body'

      it 'has a subject' do
        expect(mail.subject).to eq('Nye saker fra Stortinget: 1 behandlet')
      end
    end

    context 'without votes' do
      it 'is not created if there are no votes' do
        expect(mail.to).to be_nil
      end
    end

    context 'with new parliament issues' do
      before do
        parliament_issue.created_at = 23.hours.ago
      end

      after do
        parliament_issue.destroy
      end

      it_behaves_like 'mail with body'

      it 'is created with the correct subject' do
        expect(mail.subject).to eq('Nye saker fra Stortinget: 1 mottatt')
      end
    end

    context 'with votes and parliament issues' do
      let(:upcoming) { ParliamentIssue.make!(:status => "til_behandling") }

      before do
        parliament_issue.created_at = 23.hours.ago
        upcoming.created_at = 23.hours.ago
        vote.created_at = 23.hours.ago
      end

      after do
        parliament_issue.destroy
        upcoming.destroy
        vote.destroy
      end

      it_behaves_like 'mail with body'

      it 'is created with the correct subject' do
        expect(mail.subject).to eq('Nye saker fra Stortinget: 1 behandlet, 1 mottatt, 1 til behandling')
      end
    end

  end
end
