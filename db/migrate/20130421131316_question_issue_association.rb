class QuestionIssueAssociation < ActiveRecord::Migration
    def up
    create_table :issues_questions, :id => false do |t|
      t.references :question, :issue
    end

    add_index :issues_questions, [:question_id, :issue_id]
  end

  def down
    drop_table :issues_questions
  end
end
