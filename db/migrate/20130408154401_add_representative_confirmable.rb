class AddRepresentativeConfirmable < ActiveRecord::Migration
def up
    add_column :representatives, :confirmation_token, :string
    add_column :representatives, :confirmed_at, :datetime
    add_column :representatives, :confirmation_sent_at, :datetime
    add_index :representatives, :confirmation_token, :unique => true

    # User.update_all({:confirmed_at => DateTime.now, :confirmation_token => "Grandfathered Account", :confirmation_sent_at => DateTime.now})
  end

  def down
    remove_column :representatives, [:confirmed_at, :confirmation_token, :confirmation_sent_at]
  end
end
