require 'rails_helper'

RSpec.describe Bet, type: :model do

  it "should be able to make a bet" do
    @u1 = User.create!(name: 'Betty',
                       email: 'Betty@betwork.com',
                       password: 'password',
                       actualBalance: 1000)

    @u2 = User.create!(name: 'Betty1',
                       email: 'Betty1@betwork.com',
                       password: 'password1',
                       actualBalance: 1000)

    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")

    @bet = Bet.create!("home_team_name": "Los Angeles Lakers",
                       "away_team_name": "Chicago Bulls",
                       "betting_on": "Los Angeles Lakers",
                       "home_money_line": 225,
                       "away_money_line": 225,
                       "user_one_name": @u1.name,
                       "user_two_name": @u2.name,
                       "amount": 10,
                       "user_id_one": @u1.id,
                       "user_id_two": @u2.id,
                       "date": "dummy_date",
                       "status": 'proposed')
    expect(@bet).to be_valid
  end

  it "should be able to find all bets associated with user_id" do
    @u1 = User.create!(name: 'Betty',
                       email: 'Betty@betwork.com',
                       password: 'password',
                       actualBalance: 1000)
    @u2 = User.create!(name: 'Betty1',
                       email: 'Betty1@betwork.com',
                       password: 'password1',
                       actualBalance: 1000)
    @u3 = User.create!(name: 'Betty2',
                       email: 'Betty2@betwork.com',
                       password: 'password2',
                       actualBalance: 1000)

    @follow = Follow.create!("followable_type": "User", "followable_id": @u1.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")
    @follow1 = Follow.create!("followable_type": "User", "followable_id": @u3.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")

    @bet = Bet.create!("home_team_name": "Los Angeles Lakers",
                       "away_team_name": "Chicago Bulls",
                       "betting_on": "Los Angeles Lakers",
                       "home_money_line": 225,
                       "away_money_line": 225,
                       "user_one_name": @u1.name,
                       "user_two_name": @u2.name,
                       "amount": 10,
                       "user_id_one": @u1.id,
                       "user_id_two": @u2.id,
                       "date": "dummy_date",
                       "status": 'proposed')
    @bet = Bet.create!("home_team_name": "Los Angeles Lakers",
                       "away_team_name": "Chicago Bulls",
                       "betting_on": "Los Angeles Lakers",
                       "home_money_line": 225,
                       "away_money_line": 225,
                       "user_one_name": @u3.name,
                       "user_two_name": @u1.name,
                       "amount": 15,
                       "user_id_one": @u3.id,
                       "user_id_two": @u1.id,
                       "date": "dummy_date",
                       "status": 'proposed')
    @bets = Bet.get_by_userid(@u2.id)
    for b in @bets
      expect((b.user_id_one == @u1.id or b.user_id_two == @u1.id))
    end
  end

  it "should be able to find all bets associated with user_id even if user unfollowed friend" do
    @u1 = User.create!(name: 'Betty',
                       email: 'Betty@betwork.com',
                       password: 'password',
                       actualBalance: 1000)
    @u2 = User.create!(name: 'Betty1',
                       email: 'Betty1@betwork.com',
                       password: 'password1',
                       actualBalance: 1000)
    @u3 = User.create!(name: 'Betty2',
                       email: 'Betty2@betwork.com',
                       password: 'password2',
                       actualBalance: 1000)

    @follow = Follow.create!("followable_type": "User", "followable_id": @u1.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")
    @follow1 = Follow.create!("followable_type": "User", "followable_id": @u3.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")

    @bet = Bet.create!("home_team_name": "Los Angeles Lakers",
                       "away_team_name": "Chicago Bulls",
                       "betting_on": "Los Angeles Lakers",
                       "home_money_line": 225,
                       "away_money_line": 225,
                       "user_one_name": @u1.name,
                       "user_two_name": @u2.name,
                       "amount": 10,
                       "user_id_one": @u1.id,
                       "user_id_two": @u2.id,
                       "date": "dummy_date",
                       "status": 'proposed')
    @bet = Bet.create!("home_team_name": "Los Angeles Lakers",
                       "away_team_name": "Chicago Bulls",
                       "betting_on": "Los Angeles Lakers",
                       "home_money_line": 225,
                       "away_money_line": 225,
                       "user_one_name": @u3.name,
                       "user_two_name": @u1.name,
                       "amount": 15,
                       "user_id_one": @u3.id,
                       "user_id_two": @u1.id,
                       "date": "dummy_date",
                       "status": 'proposed')

    @follow1.destroy

    expect(Bet.count == 2)
    @bets = Bet.get_by_userid(@u2.id)
    for b in @bets
      expect((b.user_id_one == @u1.id or b.user_id_two == @u1.id))
    end
  end

end