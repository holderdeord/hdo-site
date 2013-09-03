class AddApprovedAtToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :approved_at, :datetime
  end
end
