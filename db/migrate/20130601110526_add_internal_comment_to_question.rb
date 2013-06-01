class AddInternalCommentToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :internal_comment, :string
  end
end
