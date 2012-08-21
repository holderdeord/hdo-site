class RenameTopicToIssue < ActiveRecord::Migration
  def up
    # remove indeces
    remove_index :categories_topics, [:category_id, :topic_id]
    remove_index :fields_topics, [:field_id, :topic_id]
    remove_index :promises_topics, [:promise_id, :topic_id]
    remove_index :topics, [:slug]
    remove_index :vote_connections, [:vote_id, :topic_id]

    # rename the table
    rename_table :topics, :issues

    # rename columns on join tables
    rename_column :categories_topics, :topic_id, :issue_id
    rename_column :fields_topics, :topic_id, :issue_id
    rename_column :promises_topics, :topic_id, :issue_id
    rename_column :vote_connections, :topic_id, :issue_id

    # rename join tables
    rename_table :categories_topics, :categories_issues
    rename_table :fields_topics, :fields_issues
    rename_table :promises_topics, :issues_promises

    # re-add indeces
    add_index :issues, [:slug], unique: true
    add_index :issues_promises, [:issue_id, :promise_id]
    add_index :fields_issues, [:field_id, :issue_id]
    add_index :categories_issues, [:category_id, :issue_id]
    add_index :vote_connections, [:vote_id, :issue_id]
  end

  def down
    # remove indeces
    remove_index :categories_issues, [:category_id, :issue_id]
    remove_index :fields_issues, [:field_id, :issue_id]
    remove_index :issues_promises, [:issue_id, :promise_id]
    remove_index :issues, :slug

    # rename join tables
    rename_table :issues_promises, :promises_topics
    rename_table :fields_issues, :fields_topics
    rename_table :categories_issues, :categories_topics

    # rename columns on join tables
    rename_column :promises_topics, :issue_id, :topic_id
    rename_column :fields_topics, :issue_id, :topic_id
    rename_column :categories_topics, :issue_id, :topic_id
    rename_column :vote_connections, :issue_id, :topic_id

    # rename the table
    rename_table :issues, :topics

    # add inceces
    add_index :topics, :slug, unique: true
    add_index :promises_topics, [:promise_id, :topic_id]
    add_index :fields_topics, [:field_id, :topic_id]
    add_index :categories_topics, [:category_id, :topic_id]
    add_index :vote_connections, [:vote_id, :topic_id]
  end
end
