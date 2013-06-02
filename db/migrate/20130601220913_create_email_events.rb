class CreateEmailEvents < ActiveRecord::Migration
  def change
    create_table :email_events do |t|
      t.string :email_address, null: false
      t.string :email_type, null: false
      t.references :email_eventable, polymorphic: true

      t.timestamps
    end

    add_index :email_events, [:id, :email_eventable_type, :email_eventable_id], :name => 'email_event_index', :unique => true
  end
end
