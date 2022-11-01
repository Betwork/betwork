class CreateOdds < ActiveRecord::Migration[5.2]
    def change
      create_table :odds do |t|
        t.string :team_one_name, null: false
        t.string :team_two_name, null: false 
        t.integer :money_line
      end
    end
  end
  