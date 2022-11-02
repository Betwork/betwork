require 'rails_helper'


RSpec.describe Bet, type: :model do

  it "able to make a bet" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1')
    @bet = Bet.create!("team_one_name": "Los Angeles Lakers", "team_two_name": "Chicago Bulls", "money_line": 225, "user_one_name": @u1.name, "user_two_name": @u2.name, "amount": 10, "user_id_one": @u1.id, "user_id_two": @u2.id)
    expect(@bet).to be_valid
  end

  it "able to find all bets associated with user_id" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1')
    @u3 = User.create!(name: 'Betty2', email: 'Betty2@betwork.com', password: 'password2')
    @bet = Bet.create!("team_one_name": "Los Angeles Lakers", "team_two_name": "Chicago Bulls", "money_line": 225, "user_one_name": @u1.name, "user_two_name": @u2.name, "amount": 10, "user_id_one": @u1.id, "user_id_two": @u2.id)
    @bet = Bet.create!("team_one_name": "Los Angeles Lakers", "team_two_name": "Chicago Bulls", "money_line": 225, "user_one_name": @u3.name, "user_two_name": @u1.name, "amount": 15, "user_id_one": @u3.id, "user_id_two": @u1.id)
    @bets = Bet.get_by_userid(@u2.id)
    for b in @bets
      expect((b.user_id_one == @u1.id or b.user_id_two == @u1.id))
    end

  end






end