class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.text    :body,              null: false
      t.integer :representative_id, null: false
      t.integer :question_id,       null: false

      t.timestamps
    end

    add_index :answers, :representative_id
  end
end
