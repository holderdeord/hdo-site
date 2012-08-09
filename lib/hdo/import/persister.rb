module Hdo
  module Import
    class Persister
      attr_writer :log

      def initialize
        @log = Logger.new(STDOUT)
      end

      def import_votes(votes)
        imported_votes = transaction do
          votes.map { |e| import_vote(e) }
        end

        infer imported_votes
      end

      def import_representatives(reps)
        transaction do
          reps.each { |e| import_representative(e) }
        end
      end

      def import_propositions(propositions)
        transaction do
          propositions.each { |e| import_proposition(e) }
        end
      end

      def import_promises(promises)
        transaction do
          promises.each { |e| import_promise(e) }
        end
      end

      def import_parties(parties)
        transaction do
          parties.each { |e| import_party(e) }
        end
      end

      def import_committees(committees)
        transaction do
          committees.each { |e| import_committee(e) }
        end
      end

      def import_categories(categories)
        transaction do
          categories.each { |e| import_category(e) }
        end
      end

      def import_districts(districts)
        transaction do
          districts.each { |e| import_district(e) }
        end
      end

      def import_issues(issues)
        transaction do
          issues.each { |e| import_issue(e) }
        end
      end

      def import_party(party)
        log_import party
        party.validate!

        record = Party.find_or_create_by_external_id party.external_id
        record.name = party.name
        record.save!

        if party.governing_periods
          record.governing_periods = []

          Array(party.governing_periods).map do |gp|
            record.governing_periods.create!(
              :start_date => gp.start_date,
              :end_date => gp.end_date
            )
          end

          record.save!
        end

        record
      end

      def import_committee(committee)
        log_import committee
        committee.validate!

        c = Committee.find_or_create_by_external_id committee.external_id
        c.update_attributes! :name => committee.name

        c
      end

      def import_category(category)
        log_import category
        category.validate!

        parent = Category.find_or_create_by_external_id category.external_id
        parent.name = category.name
        parent.main = true
        parent.save!

        category.children.each do |subcategory|
          log_import subcategory
          child = Category.find_or_create_by_external_id(subcategory.external_id)
          child.name = subcategory.name
          child.save!

          parent.children << child
        end
      end

      def import_district(district)
        log_import district
        district.validate!

        d = District.find_or_create_by_external_id district.external_id
        d.update_attributes! :name => district.name

        d
      end

      def import_issue(issue)
        log_import issue
        issue.validate!

        committee = issue.committee && Committee.find_by_name!(issue.committee)
        categories = issue.categories.map { |e| Category.find_by_name! e }

        record = Issue.find_or_create_by_external_id issue.external_id
        record.update_attributes!(
          :document_group => issue.document_group,
          :issue_type     => issue.type, # AR doesn't like :type as a column name
          :status         => issue.status,
          :last_update    => Time.parse(issue.last_update),
          :reference      => issue.reference,
          :summary        => issue.summary,
          :description    => issue.description,
          :committee      => committee,
          :categories     => categories
        )

        record
      end

      VOTE_RESULTS = {
        "for"     => 1,
        "absent"  => 0,
        "against" => -1
      }

      def import_vote(xvote)
        log_import xvote
        xvote.validate!

        vote  = Vote.find_or_create_by_external_id xvote.external_id
        issue = Issue.find_by_external_id! xvote.external_issue_id

        vote.issues << issue

        vote.update_attributes!(
          :for_count     => Integer(xvote.counts.for),
          :against_count => Integer(xvote.counts.against),
          :absent_count  => Integer(xvote.counts.absent),
          :enacted       => xvote.enacted?,
          :personal      => xvote.personal?,
          :subject       => xvote.subject,
          :time          => Time.parse(xvote.time)
        )

        xvote.representatives.each do |xrep|
          result = VOTE_RESULTS[xrep.vote_result] or raise "invalid vote result: #{result_text.inspect}"
          rep = Representative.find_by_external_id(xrep.external_id) || import_representative(xrep)

          res = VoteResult.find_or_create_by_representative_id_and_vote_id(rep.id, vote.id)
          res.result = result
          res.save!
        end

        xvote.propositions.each do |e|
          vote.propositions << import_proposition(e)
        end

        vote.save!
        vote
      end

      def import_representative(representative)
        log_import representative
        representative.validate!

        party = Party.find_by_name!(representative.party)
        committees = representative.committees.map { |name| Committee.find_by_name!(name) }
        district = District.find_by_name!(representative.district)

        dob = Time.parse(representative.date_of_birth)

        if representative.date_of_death
          dod = Time.parse(representative.date_of_death)
          dod = nil if dod.year == 1
        else
          dod = nil
        end

        rec = Representative.find_or_create_by_external_id representative.external_id
        rec.update_attributes!(
          :party         => party,
          :first_name    => representative.first_name,
          :last_name     => representative.last_name,
          :committees    => committees,
          :district      => district,
          :date_of_birth => dob,
          :date_of_death => dod
        )

        rec
      end

      def import_proposition(xprop)
        log_import xprop
        xprop.validate!

        prop = Proposition.find_or_create_by_external_id(xprop.external_id)

        attributes = {
          description: xprop.description,
          on_behalf_of: xprop.on_behalf_of,
          body: xprop.body
        }

        if xprop.delivered_by
          rep = import_representative(xprop.delivered_by)
          attributes[:representative_id] = rep.id
        end

        prop.update_attributes attributes
        prop.save!

        prop
      end

      def import_promise(promise)
        log_import promise
        promise.validate!

        categories = Category.where(name: promise.categories)
        not_found = promise.categories - categories.map(&:name)

        if not_found.any?
          raise "could not find category: #{not_found.inspect}"
        end

        Promise.create!(
          party: Party.find_by_external_id!(promise.party),
          general: promise.general?,
          categories: categories,
          source: promise.source,
          body: promise.body
        )
      end

      private

      def log_import(obj)
        @log.info "importing #{obj.short_inspect}"
      end

      def transaction(&blk)
        ActiveRecord::Base.transaction(&blk)
      end

      def infer(imported_votes)
        non_personal_votes = imported_votes.select { |v| v.non_personal? && !v.inferred? }.uniq

        inferrer     = VoteInferrer.new(non_personal_votes)
        inferrer.log = @log

        inferrer.infer!
      end

    end # Persister
  end # Import
end # Hdo