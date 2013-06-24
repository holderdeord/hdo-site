class CreateIssueOverrides < ActiveRecord::Migration
  def change
    create_table :issue_overrides do |t|
      t.references :issue
      t.references :party

      t.float  :score
      t.string :kind

      t.timestamps
    end

    add_index :issue_overrides, [:issue_id, :kind]
  end
end
