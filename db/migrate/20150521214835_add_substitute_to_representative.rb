class AddSubstituteToRepresentative < ActiveRecord::Migration
  def change
    add_column :representatives, :substitute, :boolean, default: false
  end
end
