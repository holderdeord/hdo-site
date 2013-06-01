class CreateEmailEvents < ActiveRecord::Migration
  def change
    create_table :email_events do |t|
      t.string :email_address, null: false
      t.string :email_type, null: false

      t.timestamps
    end

    create_table :email_event_connections do |t|
      t.references :email_event
      t.references :email_event_associable, polymorphic: true
    end

    add_index :email_event_connections, [:email_event_id, :email_event_associable_type, :email_event_associable_id], :name => 'email_event_association_index', :unique => true
  end
end
