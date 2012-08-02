class ChangePropositionBodyToText < ActiveRecord::Migration
  def up
    change_column :propositions, :body, :text
  end

  def down
    change_column :propositions, :body, :string
  end
end
