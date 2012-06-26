class RenameTopicToCategory < ActiveRecord::Migration
  def up
    rename_table :topics, :categories
    
    rename_table  :issues_topics,     :categories_issues
    rename_column :categories_issues, :topic_id, :category_id
    rename_index  :categories_issues, "index_issues_topics_on_issue_id_and_topic_id", "index_categories_issues_on_issue_id_and_category_id"  
    
    rename_table  :promises_topics,     :categories_promises
    rename_column :categories_promises, :topic_id, :category_id
    rename_index  :categories_promises, "index_promises_topics_on_promise_id_and_topic_id", "index_categories_promises_on_issue_id_and_category_id"  
  end

  def down
    rename_table :categories, :topics
    
    rename_table  :categories_issues, :issues_topics
    rename_column :issues_topics, :category_id, :topic_id
    rename_index  :issues_topics, "index_categories_issues_on_issue_id_and_category_id", "index_issues_topics_on_issue_id_and_topic_id"
    
    rename_table  :promises_categories, :promises_topics
    rename_column :promises_topics, :category_id, :topic_id
    rename_index  :promises_topics, "index_categories_promises_on_issue_id_and_category_id", "index_promises_topics_on_promise_id_and_topic_id"
  end
end
