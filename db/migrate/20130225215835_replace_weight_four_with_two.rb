class ReplaceWeightFourWithTwo < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE vote_connections SET weight = 2 where weight = 4
    SQL
  end

  def down
    # unavoidable data loss
  end
end
