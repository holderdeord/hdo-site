class IssueTopicAssociation < ActiveRecord::Migration
  def up
    create_table :issues_topics, :id => false do |t|
      t.references :issue, :topic
    end

    add_index :issues_topics, [:issue_id, :topic_id]
  end

  def down
    drop_table :issues_topics
  end
end
