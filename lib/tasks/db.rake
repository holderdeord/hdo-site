namespace :db do
  namespace :clear do
    desc 'Remove all votes.'
    task :votes => :environment do
      Vote.destroy_all
    end

    desc 'Remove all representatives'
    task :representatives => :environment do
      Representative.destroy_all
    end

    desc 'Remove all promises'
    task :promises => :environment do
      Promise.destroy_all
    end

    desc 'Remove all issues'
    task :issues => :environment do
      Issue.destroy_all
    end
  end

  namespace :dump do
    task :issues => :environment do
      data = Issue.all.map { |issue|
        i = issue.as_json

        # not mass-assignable
        i.delete('created_at')
        i.delete('updated_at')
        i.delete('slug')
        i.delete('id')

        i['topic_names'] = issue.topics.map { |e| e.name }
        i['promise_external_ids'] = issue.promises.map { |e| e.external_id }

        i
      }

      out = "issues.json"
      File.open(out, "w") { |io| io << data.to_json }

      puts "wrote #{out}"
    end

    task :users => :environment do
      data = User.all.as_json(:methods => :encrypted_password)

      out = "users.json"
      File.open(out, "w") { |io| io << data.to_json }

      puts "wrote #{out}"
    end
  end

  namespace :load do
    task :issues => :environment do
      file = ENV['FILE'] or raise "must set FILE"
      data = MultiJson.decode(open(file).read)

      data.each do |hash|
        topics = hash.delete('topic_names').map { |name| Topic.find_by_name!(name) }
        promises = hash.delete('promise_external_ids').map { |id| Promise.find_by_external_id!(id) }

        issue = Issue.create(hash)
        issue.topics = topics
        issue.promises = promises

        issue.save!
      end
    end

    task :users => :environment do
      file = ENV['FILE'] or raise "must set FILE"
      data = MultiJson.decode(open(file).read)

      raise NotImplementedError
    end

  end
end
