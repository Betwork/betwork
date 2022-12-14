class AddLeagueToOdds < ActiveRecord::Migration[5.2]
  def change
    add_column :odds, :league, :string
  end
end
