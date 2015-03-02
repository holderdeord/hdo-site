class AddLinksParliamentIssuesAssociation < ActiveRecord::Migration

  def up
    create_table :links_parliament_issues, :id => false do |t|
      t.references :link, :parliament_issue
    end

    add_index :links_parliament_issues, [:link_id, :parliament_issue_id], name: 'index_links_par_issues'
  end

  def down
    drop_table :links_parliament_issues
  end
end
