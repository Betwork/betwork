class CreateBets < ActiveRecord::Migration[5.2]
  def change
    create_table :bets do |t|
      t.string :team_one_name, null: false
      t.string :team_two_name, null: false
      t.integer :money_line
      t.string :user_one_name, null: false
      t.string :user_two_name, null: false
      t.integer :amount
    end
  end
end
