class CreatePartyComments < ActiveRecord::Migration
  def change
    create_table :party_comments do |t|
      t.string :body
      t.string :title
      t.references :party
      t.references :issue

      t.timestamps
    end
    add_index :party_comments, :party_id
    add_index :party_comments, :issue_id
  end
end
