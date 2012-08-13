class AddExternalIdPageAndDateToPromise < ActiveRecord::Migration
  def change
    add_column :promises, :external_id, :string
    add_column :promises, :page, :integer
    add_column :promises, :date, :date
  end
end
