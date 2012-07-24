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
      else
        raise ArgumentError, "unknown command: #{@cmd.inspect}"
      end
    end

    private

    def import_api(vote_limit = nil)
      ds = Hdo::StortingImporter::ParsingDataSource.new(api_data_source)

      import_parties ds.parties
      import_committees ds.committees
      import_districts ds.districts

      import_representatives ds.representatives
      import_representatives ds.representatives_today

      import_categories ds.categories

      issues = ds.issues

      import_issues issues
      import_votes votes_for(ds, issues, vote_limit)
    end

    def votes_for(data_source, issues, limit = nil)
      result = []

      issues.each do |issue|
        result += data_source.votes_for(issue.external_id)
        break if limit && result.size >= limit
      end

      result
    end

    def import_files
      @rest.each do |file|
        print "\nimporting #{file.inspect}:"

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
      puts " #{doc.name}"

      case doc.first_element_child.name
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
        raise "unknown type: #{doc.first_element_child.name}"
      end
    end

    def import_parties(parties)
      parties.each do |party|
        p = ::Party.find_or_create_by_external_id party.external_id
        p.update_attributes! :name => party.name

        print "."
      end
    end

    def import_committees(committees)
      committees.each do |committee|
        p = ::Committee.find_or_create_by_external_id committee.external_id
        p.update_attributes! :name => committee.name
      end
    end

    def import_categories(categories)
      categories.each do |category|
        parent = ::Category.find_or_create_by_external_id category.external_id
        parent.name = category.name
        parent.main = true
        parent.save!

        category.children.each do |subcategory|
          child = ::Category.find_or_create_by_external_id(subcategory.external_id)
          child.name = subcategory.name
          child.save!

          parent.children << child
        end

        print "."
      end
    end

    def import_districts(districts)
      districts.each do |district|
        p = ::District.find_or_create_by_external_id district.external_id
        p.update_attributes! :name => district.name

        print "."
      end
    end

    def import_issues(issues)
      issues.each do |issue|
        external_id    = issue.external_id
        document_group = issue.document_group
        issue_type     = issue.type
        status         = issue.status
        last_update    = Time.parse issue.last_update
        reference      = issue.reference
        summary        = issue.summary
        description    = issue.description

        committee = issue.committee && ::Committee.find_by_name!(issue.committee)
        categories = issue.categories.map { |e| ::Category.find_by_name! e }

        issue = ::Issue.find_or_create_by_external_id external_id
        issue.update_attributes!(
          :document_group => document_group,
          :issue_type     => issue_type, # AR doesn't like :type as a column name
          :status         => status,
          :last_update    => last_update,
          :reference      => reference,
          :summary        => summary,
          :description    => description,
          :committee      => committee,
          :categories     => categories
        )

        print "."
      end
    end

    VOTE_RESULTS = {
      "for"     => 1,
      "absent"  => 0,
      "against" => -1
    }

    def import_votes(votes)
      votes.each do |xvote|
        vote  = ::Vote.find_or_create_by_external_id xvote.external_id
        issue = ::Issue.find_by_external_id! xvote.external_issue_id

        for_count     = Integer(xvote.counts.for)
        against_count = Integer(xvote.counts.against)
        absent_count  = Integer(xvote.counts.absent)

        vote.issues << issue

        vote.update_attributes!(
          :for_count     => for_count,
          :against_count => against_count,
          :absent_count  => absent_count,
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

        props = vote.propositions.map { |e| import_proposition(e) }

        vote.propositions += props
        vote.save!

        print "."
      end
    end

    def import_representatives(reps)
      reps.each { |e| import_representative(e) }
    end

    def import_propositions(propositions)
      propositions.each { |e| import_proposition(e) }
    end

    def import_promises(promises)
      promises.each { |e| import_promise(e) }
    end

    def import_representative(representative)
      external_id     = representative.external_id
      party_name      = representative.party
      first_name      = representative.first_name
      last_name       = representative.last_name
      committee_names = representative.committees
      district_name   = representative.district
      dob             = Time.parse(representative.date_of_birth)

      if representative.date_of_death
        dod = Time.parse(representative.date_of_death)
        dod = nil if dod.year == 1
      else
        dod = nil
      end

      party = ::Party.find_by_name!(party_name)
      committees = committee_names.map { |name| ::Committee.find_by_name!(name) }
      district = ::District.find_by_name!(district_name)

      rec = ::Representative.find_or_create_by_external_id external_id_from(external_id)
      rec.update_attributes!(
        :party         => party,
        :first_name    => first_name,
        :last_name     => last_name,
        :committees    => committees,
        :district      => district,
        :date_of_birth => dob,
        :date_of_death => dod
      )

      rec
    end

    ID_CONVERSIONS = {
      '_AE' => 'Æ',
      '_O'  => 'Ø',
      '_A'  => 'Å'
    }

    def external_id_from(query_param)
      q = query_param.dup
      ID_CONVERSIONS.each { |k, v| q.gsub!(k, v) }

      q
    end

    def import_proposition(prop)
      external_id  = prop.external_id
      description  = prop.description
      on_behalf_of = prop.on_behalf_of
      body         = prop.body

      rep = import_representative(on_behalf_of) if on_behalf_of

      prop = ::Proposition.find_or_create_by_external_id(external_id)

      attributes = {
        description: description,
        on_behalf_of: on_behalf_of,
        body: body
      }

      attributes[:representative_id] = rep.id if rep

      prop.update_attributes! attributes

      prop
    end

    def import_promise(promise)
      party      = ::Party.find_by_external_id!(promise.party)
      general    = promise.general?
      categories = ::Category.where(name: promise.categories)
      source     = promise.source
      body       = promise.body

      begin
        ::Promise.create!(
          party: party,
          general: general,
          categories: categories,
          source: source,
          body: body
        )

        print "."
      rescue ActiveRecord::RecordInvalid => ex
        STDERR.puts "failed to import promise: #{ex.message} for #{party.name}, #{body.inspect}"
      end

    end

    def api_data_source
      @api_data_source ||= Hdo::StortingImporter::ApiDataSource.new("http://data.stortinget.no")
    end

  end
end
