class AddInterestingBoolToProposition < ActiveRecord::Migration
  def change
    add_column :propositions, :interesting, :boolean, default: true
  end
end
