class CreatePromiseTopicAssociation < ActiveRecord::Migration
  def up
    create_table :promises_topics, :id => false do |t|
      t.references :promise, :topic
    end

    add_index :promises_topics, [:promise_id, :topic_id]
  end

  def down
    drop_table :promises_topics
  end
end
