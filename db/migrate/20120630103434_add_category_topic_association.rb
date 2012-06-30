class AddCategoryTopicAssociation < ActiveRecord::Migration
  def up
    create_table :categories_topics, :id => false do |t|
      t.references :category, :topic
    end

    add_index :categories_topics, [:category_id, :topic_id]
  end

  def down
    drop_table :categories_topics
  end
end
