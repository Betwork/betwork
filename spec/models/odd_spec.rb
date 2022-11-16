require 'rails_helper'

RSpec.describe Odd, type: :model do

  it "should be be able to see all odds for all games" do
    Odd.create([{ home_team_name: 'Los Angeles Lakers',
                  away_team_name: 'Chicago Bulls',
                  home_money_line: +225 }])
    Odd.create([{ home_team_name: 'Los Angeles Clippers',
                  away_team_name: 'New Orleans Pelicans',
                  home_money_line: -130 }])
    Odd.create([{ home_team_name: 'Miami Heat',
                  away_team_name: 'Cleveland Cavaliers',
                  home_money_line: -170 }])
    Odd.create([{ home_team_name: 'Los Angeles Lakers',
                  away_team_name: 'Chicago Bulls',
                  home_money_line: -220 }])
    Odd.create([{ home_team_name: 'Orlando Magic',
                  away_team_name: 'Golden State Warriors',
                  home_money_line: +310 }])
    expect(Odd.count == 5)
    @odds = Odd.all
    for odd in @odds
      expect([+225, -130, -170, -220, +310].include? odd.home_money_line)
    end
  end

end