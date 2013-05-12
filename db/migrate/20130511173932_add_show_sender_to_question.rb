class AddShowSenderToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :show_sender, :boolean, default: true
  end
end
