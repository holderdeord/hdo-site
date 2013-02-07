class AddTwitterAndEmailToRepresentatives < ActiveRecord::Migration
  def change
    add_column :representatives, :twitter_id, :string
    add_column :representatives, :email, :string
  end
end
