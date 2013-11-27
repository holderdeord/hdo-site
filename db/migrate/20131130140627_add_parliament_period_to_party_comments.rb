class AddParliamentPeriodToPartyComments < ActiveRecord::Migration
  def change
    add_column :party_comments, :parliament_period_id, :integer
  end
end
