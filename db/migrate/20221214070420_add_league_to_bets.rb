class AddLeagueToBets < ActiveRecord::Migration[5.2]
  def change
    add_column :bets, :league, :string
  end
end
