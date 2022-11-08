class AddBalanceInEscrowToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :balanceInEscrow, :decimal, precision: 100, scale: 2, :default => 0.0
  end
end
