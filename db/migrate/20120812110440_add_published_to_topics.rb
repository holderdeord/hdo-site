class AddPublishedToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :published, :boolean, :default => false
  end
end
