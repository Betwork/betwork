require 'rails_helper'
# require 'spec_helper'
RSpec.describe "Odds", type: :request do
  it "should be able to pull odds" do
    @user = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @user.skip_confirmation!
    @user.save!
    sign_in @user
    allOdds = Odd.all
    expect(allOdds.length()).to eq(0)
    @params = {}
    get odds_path(@params)
    allOdds = Odd.all
    expect(allOdds.length()).to be > 0
    firstOdd = allOdds[0]
    expect(firstOdd.home_team_name).not_to be_nil
    expect(firstOdd.away_team_name).not_to be_nil
    expect(firstOdd.home_money_line).not_to be_nil
    expect(firstOdd.home_money_line).not_to be_nil
  end

  it "should be able to select a single Odd (later be used to create a Bet)" do
    @user = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @user.skip_confirmation!
    @user.save!
    sign_in @user
    @odd = Odd.create!(home_team_name: 'Los Angeles Lakers',
                       away_team_name: 'Chicago Bulls',
                       home_money_line: +225,
                       away_money_line: +225)
    allOdds = Odd.all
    expect(allOdds.length()).to eq(1)
    # puts @odd.id
    @params = { :id => @odd.id }
    result = get friends_odd_path(@params)
    expect(result).to eq(200)
  end
end


