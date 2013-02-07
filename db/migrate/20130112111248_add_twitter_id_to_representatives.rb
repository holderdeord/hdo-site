class AddTwitterIdToRepresentatives < ActiveRecord::Migration
  def change
    add_column :representatives, :twitter_id, :string
  end
end
