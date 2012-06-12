class ChangePropositionBodyToText < ActiveRecord::Migration
  def up
    # limit is somewhat arbitrary - largest seen so far is 123 541 bytes
    change_column :propositions, :body, :text, :limit => 300_000
  end

  def down
    change_column :propositions, :body, :string
  end
end
