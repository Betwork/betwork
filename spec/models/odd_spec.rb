require 'rails_helper'

RSpec.describe Odd, type: :model do

  it "should be be able to see all odds for all games" do
    Odd.create([{team_one_name: 'Los Angeles Lakers', team_two_name: 'Chicago Bulls', money_line: +225}])
    Odd.create([{team_one_name: 'Los Angeles Clippers', team_two_name: 'New Orleans Pelicans', money_line: -130}])
    Odd.create([{team_one_name: 'Miami Heat', team_two_name: 'Cleveland Cavaliers', money_line: -170 }])
    Odd.create([{team_one_name: 'Los Angeles Lakers', team_two_name: 'Chicago Bulls', money_line: -220}])
    Odd.create([{team_one_name: 'Orlando Magic', team_two_name: 'Golden State Warriors', money_line: +310}])
    expect(Odd.count == 5)
    @odds = Odd.all
    for odd in @odds
      expect([+225, -130, -170, -220, +310].include? odd.money_line)
    end
  end


end