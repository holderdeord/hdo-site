class AddCommitteeMemberships < ActiveRecord::Migration
  def up
    create_table :committee_memberships do |t|
      t.references :representative, :committee, null: false
      t.date :start_date, null: false
      t.date :end_date, default: nil

      t.timestamps
    end

    add_index :committee_memberships, [:representative_id, :committee_id, :start_date, :end_date], name: "index_committee_memberships_on_all"

    # move data
    # we can't know what data we're moving, so just assume the current session
    start_date = current_start_date.strftime("%Y-%m-%d")

    execute <<-SQL
      INSERT INTO committee_memberships (representative_id, committee_id, start_date, created_at, updated_at)
      SELECT representative_id, committee_id, date('#{start_date}'), NOW(), NOW() FROM committees_representatives
    SQL

    # delete old association
    remove_index :committees_representatives, name: "index_com_reps"
    drop_table :committees_representatives
  end

  def down
    create_table :committees_representatives, id: false do |t|
      t.references :committee, :representative
    end
    add_index :committees_representatives, [:committee_id, :representative_id], name: 'index_com_reps'

    # move data - we just add the current (i.e. open ended) memberships
    execute <<-SQL
      INSERT INTO committees_representatives (representative_id, committee_id)
      SELECT representative_id, committee_id FROM committee_memberships WHERE end_date IS NULL
    SQL

    remove_index :committee_memberships, name: 'index_committee_memberships_on_all'
    drop_table :committee_memberships
  end

  private

  def current_start_date
    now = Time.now
    new_session_start = Time.new(now.year, 10, 1)

    if now >= new_session_start
      new_session_start
    else
      Time.new(now.year - 1, 10, 1)
    end
  end
end
