class EnlargePromiseBody < ActiveRecord::Migration
  def up
    change_column :promises, :body, :text
  end

  def down
    change_column :promises, :body, :string
  end
end
