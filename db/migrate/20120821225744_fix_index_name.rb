class FixIndexName < ActiveRecord::Migration
  def up
    remove_index :categories_promises, :name => "index_categories_promises_on_issue_id_and_category_id"
    add_index :categories_promises, [:promise_id, :category_id]
  end

  def down
    remove_index :categories_promises, :name => "index_categories_promises_on_promise_id_and_category_id"
    add_index :categories_promises, [:promise_id, :category_id], :name => "index_categories_promises_on_issue_id_and_category_id"
  end
end
