# encoding: utf-8

module Hdo
  class Importer
    def initialize(argv)
      if argv.empty?
        raise ArgumentError, 'no args'
      elsif argv.include? "-h" or argv.include? "--help"
        puts "USAGE: #{PROGRAM_NAME} <xml|all|daily> [opts]"
        exit 0
      else
        @cmd = argv.shift
        @rest = argv
      end

      @log = Hdo::StortingImporter.logger
    end

    def run
      case @cmd
      when 'xml'
        import_files
      when 'daily'
        raise NotImplementedError
      when 'api'
        import_api
      when 'dev'
        import_api(30)
      when 'representatives'
        import_api_representatives
      else
        raise ArgumentError, "unknown command: #{@cmd.inspect}"
      end
    end

    private

    def import_api(vote_limit = nil)
      import_parties parsing_data_source.parties
      import_committees parsing_data_source.committees
      import_districts parsing_data_source.districts

      import_api_representatives

      import_categories parsing_data_source.categories

      issues = parsing_data_source.issues

      import_issues issues
      import_votes votes_for(parsing_data_source, issues, vote_limit)
    end

    def import_api_representatives
      import_representatives parsing_data_source.representatives
      import_representatives parsing_data_source.representatives_today
    end

    def votes_for(data_source, issues, limit = nil)
      result = []

      issues.each do |issue|
        result += data_source.votes_for(issue.external_id)
        break if limit && result.size >= limit
      end

      result
    end

    def parsing_data_source
      @parsing_data_source ||= Hdo::StortingImporter::ParsingDataSource.new(api_data_source)
    end

    def import_files
      @rest.each do |file|
        print "\nimporting #{file}:"

        str = file == "-" ? STDIN.read : File.read(file)
        doc = Nokogiri.XML(str)

        if doc
          import doc
        else
          p file => File.read(file)
          raise
        end
      end
    end

    def import(doc)
      name = doc.first_element_child.name
      puts " #{name}"

      case name
      when 'representatives'
        import_representatives StrortingImporter::Representative.from_hdo_doc doc
      when 'parties'
        import_parties StortingImporter::Party.from_hdo_doc doc
      when 'committees'
        import_committees StortingImporter::Committee.from_hdo_doc doc
      when 'categories'
        import_categories StortingImporter::Categories.from_hdo_doc doc
      when 'districts'
        import_districts StortingImporter::District.from_hdo_doc doc
      when 'issues'
        import_issues StortingImporter::Issue.from_hdo_doc doc
      when 'votes'
        import_votes StortingImporter::Vote.from_hdo_doc doc
      when 'promises'
        import_promises StortingImporter::Promise.from_hdo_doc doc
      else
        raise "unknown type: #{name}"
      end
    end

    def import_parties(parties)
      parties.each do |party|
        @log.info "importing #{party.short_inspect}"

        p = Party.find_or_create_by_external_id party.external_id
        p.update_attributes! :name => party.name

      end
    end

    def import_committees(committees)
      committees.each do |committee|
        @log.info "importing #{committee.short_inspect}"

        p = Committee.find_or_create_by_external_id committee.external_id
        p.update_attributes! :name => committee.name
      end
    end

    def import_categories(categories)
      categories.each do |category|
        @log.info "importing #{category.short_inspect}"

        parent = Category.find_or_create_by_external_id category.external_id
        parent.name = category.name
        parent.main = true
        parent.save!

        category.children.each do |subcategory|
          child = Category.find_or_create_by_external_id(subcategory.external_id)
          child.name = subcategory.name
          child.save!

          parent.children << child
        end
      end
    end

    def import_districts(districts)
      districts.each do |district|
        @log.info "importing #{district.short_inspect}"

        p = District.find_or_create_by_external_id district.external_id
        p.update_attributes! :name => district.name
      end
    end

    def import_issues(issues)
      issues.each do |issue|
        @log.info "importing #{issue.short_inspect}"

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
      end
    end

    VOTE_RESULTS = {
      "for"     => 1,
      "absent"  => 0,
      "against" => -1
    }

    def import_votes(votes)
      votes.each do |e|
        debug_on_error(e) { import_vote(e) }
      end
    end

    def import_representatives(reps)
      reps.each do |e|
        debug_on_error(e) { import_representative(e) }
      end
    end

    def import_propositions(propositions)
      propositions.each do |e|
        debug_on_error(e) { import_proposition(e) }
      end
    end

    def import_promises(promises)
      promises.each do |e|
        debug_on_error(e) { import_promise(e) }
      end
    end

    def import_vote(xvote)
      @log.info "importing #{xvote.short_inspect}"

      vote  = Vote.find_or_create_by_external_id xvote.external_id
      issue = Issue.find_by_external_id! xvote.external_issue_id

      vote.issues << issue

      vote.update_attributes!(
        :for_count     => Integer(xvote.counts.for),
        :against_count => Integer(xvote.counts.against),
        :absent_count  => Integer(xvote.counts.absent),
        :enacted       => xvote.enacted?,
        :subject       => xvote.subject,
        :time          => Time.parse(xvote.time)
      )

      xvote.representatives.each do |xrep|
        result = VOTE_RESULTS[xrep.vote_result] or raise "invalid vote result: #{result_text.inspect}"
        rep = import_representative(xrep)

        res = VoteResult.find_or_create_by_representative_id_and_vote_id(rep.id, vote.id)
        res.result = result
        res.save!
      end

      xvote.propositions.each do |e|
        vote.propositions << import_proposition(e)
      end

      vote.save!
    end

    def import_representative(representative)
      @log.info "importing #{representative.short_inspect}"

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
      @log.info "importing #{xprop.short_inspect}"

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
      @log.info "importing #{promise.short_inspect}"

      Promise.create!(
        party: Party.find_by_external_id!(promise.party),
        general: promise.general?,
        categories: Category.where(name: promise.categories),
        source: promise.source,
        body: promise.body
      )
    end

    def debug_on_error(obj, &blk)
      yield
    rescue
      puts obj
      raise
    end

    def api_data_source
      @api_data_source ||= Hdo::StortingImporter::ApiDataSource.new("http://data.stortinget.no")
    end

  end
end
