class AddSimpleFieldsToProposition < ActiveRecord::Migration
  def change
    add_column :propositions, :simple_description, :string
    add_column :propositions, :simple_body, :text
  end
end
