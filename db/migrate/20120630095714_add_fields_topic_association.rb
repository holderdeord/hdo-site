class AddFieldsTopicAssociation < ActiveRecord::Migration
  def up
    create_table :fields_topics, :id => false do |t|
      t.references :field, :topic
    end

    add_index :fields_topics, [:field_id, :topic_id]
  end

  def down
    drop_table :fields_topics
  end
end
