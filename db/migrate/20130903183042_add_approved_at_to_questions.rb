class AddApprovedAtToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :approved_at, :datetime
    execute "UPDATE questions SET approved_at = updated_at WHERE status = 'approved'"
  end
end
