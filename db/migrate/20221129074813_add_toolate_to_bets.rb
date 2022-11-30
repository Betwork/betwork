class AddToolateToBets < ActiveRecord::Migration[5.2]
  def change
    add_column :bets, :toolate, :boolean
  end
end
