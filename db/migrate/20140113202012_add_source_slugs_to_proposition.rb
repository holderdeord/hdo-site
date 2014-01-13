class AddSourceSlugsToProposition < ActiveRecord::Migration
  def change
    add_column :propositions, :source_slugs, :string
  end
end
