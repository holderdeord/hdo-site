class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title, null: false, limit: 255
      t.text   :body,  null: false
      t.string :sender

      t.timestamps
    end
  end
end
