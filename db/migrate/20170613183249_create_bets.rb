class CreateBets < ActiveRecord::Migration[5.2]
  def change
    create_table :bets do |t|
      t.string :home_team_name, null: false
      t.string :away_team_name, null: false
      t.string :betting_on, null: false
      t.integer :home_money_line
      t.integer :away_money_line
      t.string :user_one_name, null: false
      t.string :user_two_name, null: false
      t.integer :amount
      t.integer :user_id_one
      t.integer :user_id_two
    end
  end
end
