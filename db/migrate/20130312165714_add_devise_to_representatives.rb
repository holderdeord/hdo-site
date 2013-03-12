class AddDeviseToRepresentatives < ActiveRecord::Migration
  def self.up
    change_table(:representatives) do |t|
      ## Database authenticatable
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
    end

    add_index :representatives, :email,                :unique => true
    add_index :representatives, :reset_password_token, :unique => true
  end

  def self.down
    remove_index :representatives, :reset_password_token
    remove_index :representatives, :email

    remove_column :representatives, :encrypted_password
    remove_column :representatives, :reset_password_token
    remove_column :representatives, :reset_password_sent_at
    remove_column :representatives, :remember_created_at
    remove_column :representatives, :sign_in_count
    remove_column :representatives, :current_sign_in_at
    remove_column :representatives, :last_sign_in_at
    remove_column :representatives, :current_sign_in_ip
    remove_column :representatives, :last_sign_in_ip
  end
end
