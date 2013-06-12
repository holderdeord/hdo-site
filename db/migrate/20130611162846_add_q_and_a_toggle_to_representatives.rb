class AddQAndAToggleToRepresentatives < ActiveRecord::Migration
  def change
    add_column :representatives, :will_not_answer, :boolean
  end
end
