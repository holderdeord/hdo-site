class AddOnLeaveToRepresentative < ActiveRecord::Migration
  def change
    add_column :representatives, :on_leave, :boolean, default: false
  end
end
