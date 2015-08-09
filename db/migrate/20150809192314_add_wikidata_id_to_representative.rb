class AddWikidataIdToRepresentative < ActiveRecord::Migration
  def change
    add_column :representatives, :wikidata_id, :string
  end
end
