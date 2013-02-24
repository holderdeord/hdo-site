class MoveTopicsToTags < ActiveRecord::Migration
  def up
    # move topics to tags
    execute 'INSERT INTO "tags" ("name") SELECT LOWER(name) FROM topics;'

    execute <<-SQL
      INSERT INTO "taggings" ("context", "created_at", "tag_id", "taggable_id", "taggable_type", "tagger_id", "tagger_type")
      SELECT 'tags', NOW(), tags.id, issues_topics.issue_id, 'Issue', NULL, NULL
        FROM tags AS tags
        JOIN topics AS topics ON LOWER(topics.name) = tags.name
        JOIN issues_topics ON issues_topics.topic_id = topics.id;
    SQL

    # remove join model
    drop_table :issues_topics

    # remove topics
    drop_table :topics
  end

  def down
    # create topics
    create_table :topics do |t|
      t.string   "name"
      t.string   "slug"
      t.string   "image_uid"
      t.string   "image_name"

      t.timestamps
    end

    create_table :issues_topics, id: false do |t|
      t.references :topic, :issue
    end

    add_index :issues_topics, [:issue_id, :topic_id]

    # move tags to topics
    execute <<-SQL
      INSERT INTO "topics" ("name", "slug", "image_uid", "image_name", "created_at", "updated_at")
      SELECT tags.name, LOWER(tags.name), NULL, NULL, NOW(), NOW() FROM tags
    SQL
    
    execute <<-SQL
      INSERT INTO "issues_topics" ("issue_id", "topic_id")
      SELECT issues.id, topics.id
      FROM issues 
      JOIN taggings as taggings on taggings.taggable_id = issues.id
      JOIN tags as tags on taggings.tag_id = tags.id
      JOIN topics as topics on topics.name = tags.name
    SQL
  end
end
