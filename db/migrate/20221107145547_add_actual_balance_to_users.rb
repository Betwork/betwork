class AddActualBalanceToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :actualBalance, :decimal, precision: 100, scale: 2
  end
end
