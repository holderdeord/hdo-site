class AddRepresentativeIdToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :representative_id, :integer
  end
end
