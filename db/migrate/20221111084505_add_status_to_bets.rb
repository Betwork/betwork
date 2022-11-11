class AddStatusToBets < ActiveRecord::Migration[5.2]
  def change
    add_column :bets, :status, :string
  end
end
