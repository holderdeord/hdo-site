class ChangeOnLeaveToAttending < ActiveRecord::Migration
  def change
    add_column    :representatives, :attending, :boolean, default: false
    remove_column :representatives, :on_leave

    add_index :representatives, :attending
  end
end
