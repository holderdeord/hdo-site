class ChangeVoteSubjectFromStringToText < ActiveRecord::Migration
  def up
    change_column :votes, :subject, :text
  end

  def down
    change_column :votes, :subject, :string
  end
end
