class CreateQuestionsAndAnswers < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title, null: false, limit: 255
      t.text   :body,   null: false
      t.string :status, null: false, default: 'pending'

      t.string :from_name
      t.string :from_email

      t.timestamps
    end

    create_table :answers do |t|
      t.text :body, null: false

      t.references :question
      t.references :representative

      t.string :status, null: false, default: 'pending'

      t.timestamps
    end
  end
end
