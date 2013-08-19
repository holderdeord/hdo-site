class AddRejectionReasonToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :rejection_reason, :text
  end
end
