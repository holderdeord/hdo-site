class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.string   :external_id
      t.integer  :issue_id
      t.integer  :for_count
      t.integer  :against_count
      t.integer  :missing_count
      t.boolean  :enacted
      t.string   :subject
      t.datetime :time

      t.timestamps
    end
  end
end
