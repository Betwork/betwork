class AddToolateToOdds < ActiveRecord::Migration[5.2]
  def change
    add_column :odds, :toolate, :boolean
  end
end
