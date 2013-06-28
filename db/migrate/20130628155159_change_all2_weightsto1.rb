class ChangeAll2Weightsto1 < ActiveRecord::Migration
  def up
    execute "UPDATE vote_connections SET weight = 1 WHERE weight = 2;"
  end

  def down
  end
end
