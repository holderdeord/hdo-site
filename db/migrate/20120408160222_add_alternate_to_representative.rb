class AddAlternateToRepresentative < ActiveRecord::Migration
  def change
    add_column :representatives, :alternate, :boolean
  end
end
