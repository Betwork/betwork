# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Odd.create([{team_one_name: 'Los Angeles Lakers', team_two_name: 'Chicago Bulls', money_line: +225}])
Odd.create([{team_one_name: 'Los Angeles Clippers', team_two_name: 'New Orleans Pelicans', money_line: -130}])
Odd.create([{team_one_name: 'Miami Heat', team_two_name: 'Cleveland Cavaliers', money_line: -170 }])
Odd.create([{team_one_name: 'Los Angeles Lakers', team_two_name: 'Chicago Bulls', money_line: -220}])
Odd.create([{team_one_name: 'Orlando Magic', team_two_name: 'Golden State Warriors', money_line: +310}])
