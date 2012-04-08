class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :external_id
      t.string :summary
      t.string :description
      t.string :issue_type
      t.string :status
      t.datetime :last_update
      t.string :document_group
      t.string :reference
      t.integer :committee_id

      t.timestamps
    end
  end
end
