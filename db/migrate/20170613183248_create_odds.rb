class CreateOdds < ActiveRecord::Migration[5.2]
    def change
      create_table :odds do |t|
        t.string :home_team_name, null: false
        t.string :away_team_name, null: false 
        t.integer :home_money_line
        t.integer :away_money_line
      end
    end
  end
  