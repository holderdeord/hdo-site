class RenameWillNotAnswerToOptedOut < ActiveRecord::Migration
  def up
    rename_column :representatives, :will_not_answer, :opted_out
  end

  def down
    rename_column :representatives, :opted_out, :will_not_answer
  end
end
