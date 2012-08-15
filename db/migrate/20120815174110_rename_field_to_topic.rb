class RenameFieldToTopic < ActiveRecord::Migration
  def up
    # remove indeces
    remove_index :fields, :slug
    remove_index :fields_issues, [:field_id, :issue_id]

    # rename the table
    rename_table :fields, :topics

    # rename columns on join tables
    rename_column :fields_issues, :field_id, :topic_id

    # rename join tables
    rename_table :fields_issues, :issues_topics

    # re-add indeces
    add_index :issues_topics, [:issue_id, :topic_id]
    add_index :topics, :slug, unique: true
  end

  def down
  # remove indeces
  remove_index :topics, :slug
  remove_index :issues_topics, [:field_id, :topic_id]

    # rename join tables
    rename_table :issues_topics, :fields_issues

    # rename columns on join tables
    rename_column :fields_issues, :topic_id, :field_id

    # rename the table
    rename_table :topic, :fields

    # add inceces
    add_index :fields_issues, [:field_id, :issue_id]
    add_index :fields, :slug, unique: true
  end
end
