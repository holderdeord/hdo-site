class CreateValenceIssueExplanations < ActiveRecord::Migration
  def change
    create_table :valence_issue_explanations do |t|
      t.text :explanation
      t.references :issue

      t.timestamps
    end

    create_table :parties_valence_issue_explanations, id: false do |t|
      t.references :valence_issue_explanation, :party
    end
  end
end
