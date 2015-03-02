class CreateLinks < ActiveRecord::Migration
  def up
    create_table :links do |t|
      t.string  :external_id
      t.text    :title
      t.text    :href
      t.string  :link_type
      t.string  :link_sub_type
    end
  end

  def down
    drop_table :links
  end
end
