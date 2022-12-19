require 'rails_helper'

RSpec.describe "Home", type: :request do

  it "NBA should be able to make a bet and user 1 wins" do
    originalBal_u1 = 1000
    originalBal_u2 = 2000
    dummy_game = [{ "id" => "5215e0df660ce32c023f3bbf29bf9c76", "sport_key" => "icehockey_nhl", "sport_title" => "NHL", "commence_time" => "2022-12-21T03:30:00Z", "completed" => true, "home_team" => "Los Angeles Kings", "away_team" => "Anaheim Ducks", "scores" => nil, "last_update" => nil, }]
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: originalBal_u1)
    @u1.skip_confirmation!
    @u1.save!
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1', actualBalance: originalBal_u2)
    @u2.skip_confirmation!
    @u2.save!
    admin_user = User.create!(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    admin_user.skip_confirmation!
    admin_user.save!
    sign_in @u1
    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")
    @odd1 = Odd.create!(home_team_name: 'NYK',
                        away_team_name: 'OKC',
                        home_money_line: -210,
                        away_money_line: 175,
                        date: "12:10 ET 11/13/2023",
                        league: "NBA")

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams = { :home_team_name => @odd1.home_team_name,
                   :away_team_name => @odd1.away_team_name,
                   :home_money_line => @odd1.home_money_line,
                   :date => @odd1.date,
                   :away_money_line => @odd1.away_money_line,
                   :user_one_name => @u1.name,
                   :betting_on => "Away Team",
                   :user_two_name => @u2.name,
                   :amount => 125,
                   :user_id_one => @u1.id,
                   :user_id_two => @u2.id,
                   :status => "proposed",
                   :toolate_boolean => true,
                   :league => "NBA" }

    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams[:amount] = 300
    @betparams[:betting_on] = "Home Team"
    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @betparams[:amount] = 175
    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    expect(allBets.length()).to eq(3)

    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[1].amount + allBets[2].amount)
    expect(allUsers[0].actualBalance).to eq(@u1.actualBalance)
    expect(allUsers[1].balanceInEscrow).to eq(0)
    expect(allUsers[1].actualBalance).to eq(@u2.actualBalance)

    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    #cancel the second bet PROPOSED bet, escrow balance should reset
    @params = { :id => allBets[1].id }
    get cancel_bet_path(@params)

    allBets = Bet.all
    expect(allBets.length()).to eq(3)
    expect(allBets[1].status).to eq("cancelled")
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[2].amount)
    expect(allUsers[1].balanceInEscrow).to eq(0)

    #sign in as @u2
    sign_out @u1
    sign_in @u2

    #accept the bet, balance in escrow should increase for @u2
    @params = { :id => allBets[0].id }
    get receive_bet_path(@params)
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[2].amount)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #cancel the other bet, balance in escrow should decrease for @u1
    @params = { :id => allBets[2].id }
    get cancel_bet_path(@params)

    sign_out @u2
    sign_in @u1
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #the Away team wins in this game
    allBets = Bet.all

    if (allBets[0].away_money_line > 0.0)
      @winning_amount = (allBets[0].amount / 100.0) * allBets[0].away_money_line
    else
      @winning_amount = (allBets[0].amount / (-allBets[0].away_money_line)) * 100.0
    end

    # puts "test winning amt"
    # puts @winning_amount

    #update the time of the bet
    @odd1.update(date: "12:10 ET 11/13/2022")
    # update u1 and u2 bets
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    @params = { :id => @u2.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    allUsers = User.all
    expect(allUsers[0].actualBalance).to eq(originalBal_u1 + @winning_amount)
    expect(allUsers[1].actualBalance).to eq(originalBal_u2 - allBets[0].amount)
  end

  it "should be able to access the home page" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: 100, balanceInEscrow: 0)
    @u1.skip_confirmation!
    @u1.save!
    sign_in @u1
    get about_path
    get find_friends_path
    get root_path
  end

  it "NBA should be able to make a bet and user 2 wins" do
    originalBal_u1 = 1000
    originalBal_u2 = 2000
    dummy_game = [{ "id" => "5215e0df660ce32c023f3bbf29bf9c76", "sport_key" => "icehockey_nhl", "sport_title" => "NHL", "commence_time" => "2022-12-21T03:30:00Z", "completed" => false, "home_team" => "Los Angeles Kings", "away_team" => "Anaheim Ducks", "scores" => nil, "last_update" => nil }]
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: originalBal_u1)
    @u1.skip_confirmation!
    @u1.save!
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1', actualBalance: originalBal_u2)
    @u2.skip_confirmation!
    @u2.save!
    admin_user = User.create!(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    admin_user.skip_confirmation!
    admin_user.save!
    sign_in @u1
    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")
    @odd1 = Odd.create!(home_team_name: 'NYK',
                        away_team_name: 'OKC',
                        home_money_line: -210,
                        away_money_line: 175,
                        date: "12:10 ET 11/13/2023",
                        league: "NBA")

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams = { :home_team_name => @odd1.home_team_name,
                   :away_team_name => @odd1.away_team_name,
                   :home_money_line => @odd1.home_money_line,
                   :date => @odd1.date,
                   :away_money_line => @odd1.away_money_line,
                   :user_one_name => @u1.name,
                   :betting_on => "Home Team",
                   :user_two_name => @u2.name,
                   :amount => 125,
                   :user_id_one => @u1.id,
                   :user_id_two => @u2.id,
                   :status => "proposed",
                   :league => "NBA" }

    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams[:amount] = 300
    @betparams[:betting_on] = "Home Team"
    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @betparams[:amount] = 175
    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    expect(allBets.length()).to eq(3)

    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[1].amount + allBets[2].amount)
    expect(allUsers[0].actualBalance).to eq(@u1.actualBalance)
    expect(allUsers[1].balanceInEscrow).to eq(0)
    expect(allUsers[1].actualBalance).to eq(@u2.actualBalance)

    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    #cancel the second bet PROPOSED bet, escrow balance should reset
    @params = { :id => allBets[1].id }
    get cancel_bet_path(@params)

    allBets = Bet.all
    expect(allBets.length()).to eq(3)
    expect(allBets[1].status).to eq("cancelled")
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[2].amount)
    expect(allUsers[1].balanceInEscrow).to eq(0)

    #sign in as @u2
    sign_out @u1
    sign_in @u2

    #accept the bet, balance in escrow should increase for @u2
    @params = { :id => allBets[0].id }
    get receive_bet_path(@params)
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[2].amount)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #cancel the other bet, balance in escrow should decrease for @u1
    @params = { :id => allBets[2].id }
    get cancel_bet_path(@params)

    sign_out @u2
    sign_in @u1
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #the Away team wins in this game
    allBets = Bet.all
    if (allBets[0].away_money_line > 0.0)
      @winning_amount = (allBets[0].amount / 100.0) * allBets[0].away_money_line
    else
      @winning_amount = (allBets[0].amount / (-allBets[0].away_money_line)) * 100.0
    end

    #update the time of the bet
    @odd1.update(date: "12:10 ET 11/13/2022")
    # update u1 and u2 bets
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    @params = { :id => @u2.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    #update the time of the bet
    @odd1.update(date: "12:10 ET 11/13/2022")
    # update u1 and u2 bets
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    @params = { :id => @u2.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    allUsers = User.all

    expect(allUsers[0].actualBalance).to eq(originalBal_u1 - allBets[0].amount)
    expect(allUsers[1].actualBalance).to eq(originalBal_u2 + @winning_amount)
  end

  it "NBA should be able to make a bet and user 2 wins" do
    originalBal_u1 = 1000
    originalBal_u2 = 2000
    dummy_game = [{ "id" => "5215e0df660ce32c023f3bbf29bf9c76", "sport_key" => "icehockey_nhl", "sport_title" => "NHL", "commence_time" => "2022-12-21T03:30:00Z", "completed" => false, "home_team" => "Los Angeles Kings", "away_team" => "Anaheim Ducks", "scores" => nil, "last_update" => nil }]
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: originalBal_u1)
    @u1.skip_confirmation!
    @u1.save!
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1', actualBalance: originalBal_u2)
    @u2.skip_confirmation!
    @u2.save!
    admin_user = User.create!(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    admin_user.skip_confirmation!
    admin_user.save!
    sign_in @u1
    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")
    @odd1 = Odd.create!(home_team_name: 'NYK',
                        away_team_name: 'OKC',
                        home_money_line: -210,
                        away_money_line: 175,
                        date: "12:10 ET 11/13/2023",
                        league: "NBA")

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams = { :home_team_name => @odd1.home_team_name,
                   :away_team_name => @odd1.away_team_name,
                   :home_money_line => @odd1.home_money_line,
                   :date => @odd1.date,
                   :away_money_line => @odd1.away_money_line,
                   :user_one_name => @u1.name,
                   :betting_on => "Home Team",
                   :user_two_name => @u2.name,
                   :amount => 125,
                   :user_id_one => @u1.id,
                   :user_id_two => @u2.id,
                   :status => "proposed",
                   :league => "NBA" }

    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    expect(allBets.length()).to eq(1)

    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount)
    expect(allUsers[0].actualBalance).to eq(@u1.actualBalance)
    expect(allUsers[1].balanceInEscrow).to eq(0)
    expect(allUsers[1].actualBalance).to eq(@u2.actualBalance)

    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    #sign in as @u2
    sign_out @u1
    sign_in @u2

    #accept the bet, balance in escrow should increase for @u2
    @params = { :id => allBets[0].id }
    get receive_bet_path(@params)
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #cancel the confirmed bet, balance in escrow should decrease for @u1
    @params = { :id => allBets[0].id }
    get cancel_bet_path(@params)

    sign_out @u2
    sign_in @u1
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    # expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

  end

  it "NBA time change path" do
    originalBal_u1 = 1000
    originalBal_u2 = 2000
    dummy_game = [{ "id" => "5215e0df660ce32c023f3bbf29bf9c76", "sport_key" => "icehockey_nhl", "sport_title" => "NHL", "commence_time" => "2022-12-21T03:30:00Z", "completed" => false, "home_team" => "Los Angeles Kings", "away_team" => "Anaheim Ducks", "scores" => nil, "last_update" => nil }]
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: originalBal_u1)
    @u1.skip_confirmation!
    @u1.save!
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1', actualBalance: originalBal_u2)
    @u2.skip_confirmation!
    @u2.save!
    admin_user = User.create!(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    admin_user.skip_confirmation!
    admin_user.save!
    sign_in @u1
    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")
    @odd1 = Odd.create!(home_team_name: 'NYK',
                        away_team_name: 'OKC',
                        home_money_line: -210,
                        away_money_line: 175,
                        date: "12:10 ET 11/13/2023",
                        league: "NBA")

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams = { :home_team_name => @odd1.home_team_name,
                   :away_team_name => @odd1.away_team_name,
                   :home_money_line => @odd1.home_money_line,
                   :date => @odd1.date,
                   :away_money_line => @odd1.away_money_line,
                   :user_one_name => @u1.name,
                   :betting_on => "Home Team",
                   :user_two_name => @u2.name,
                   :amount => 125,
                   :user_id_one => @u1.id,
                   :user_id_two => @u2.id,
                   :status => "confirmed",
                   :league => "NBA" }

    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    expect(allBets.length()).to eq(1)

    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount)
    expect(allUsers[0].actualBalance).to eq(@u1.actualBalance)
    expect(allUsers[1].balanceInEscrow).to eq(0)
    expect(allUsers[1].actualBalance).to eq(@u2.actualBalance)

    @params = { :id => @u1.name, :fakedata => true, :forcetimeupdatefortest => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
  end

  it "NFL should be able to make a bet and user 1 wins" do
    originalBal_u1 = 1000
    originalBal_u2 = 2000
    dummy_game = [{ "id" => "5215e0df660ce32c023f3bbf29bf9c76", "sport_key" => "icehockey_nhl", "sport_title" => "NHL", "commence_time" => "2022-12-21T03:30:00Z", "completed" => false, "home_team" => "Los Angeles Kings", "away_team" => "Anaheim Ducks", "scores" => nil, "last_update" => nil }]
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: originalBal_u1)
    @u1.skip_confirmation!
    @u1.save!
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1', actualBalance: originalBal_u2)
    @u2.skip_confirmation!
    @u2.save!
    admin_user = User.create!(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    admin_user.skip_confirmation!
    admin_user.save!
    sign_in @u1
    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")
    @odd1 = Odd.create!(home_team_name: 'NYK',
                        away_team_name: 'OKC',
                        home_money_line: -210,
                        away_money_line: 175,
                        date: "12:10 ET 11/13/2023",
                        league: "NFL")

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams = { :home_team_name => @odd1.home_team_name,
                   :away_team_name => @odd1.away_team_name,
                   :home_money_line => @odd1.home_money_line,
                   :date => @odd1.date,
                   :away_money_line => @odd1.away_money_line,
                   :user_one_name => @u1.name,
                   :betting_on => "Away Team",
                   :user_two_name => @u2.name,
                   :amount => 125,
                   :user_id_one => @u1.id,
                   :user_id_two => @u2.id,
                   :status => "proposed",
                   :league => "NFL" }

    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams[:amount] = 300
    @betparams[:betting_on] = "Home Team"
    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @betparams[:amount] = 175
    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    expect(allBets.length()).to eq(3)

    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[1].amount + allBets[2].amount)
    expect(allUsers[0].actualBalance).to eq(@u1.actualBalance)
    expect(allUsers[1].balanceInEscrow).to eq(0)
    expect(allUsers[1].actualBalance).to eq(@u2.actualBalance)

    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    #cancel the second bet PROPOSED bet, escrow balance should reset
    @params = { :id => allBets[1].id }
    get cancel_bet_path(@params)

    allBets = Bet.all
    expect(allBets.length()).to eq(3)
    expect(allBets[1].status).to eq("cancelled")
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[2].amount)
    expect(allUsers[1].balanceInEscrow).to eq(0)

    #sign in as @u2
    sign_out @u1
    sign_in @u2

    #accept the bet, balance in escrow should increase for @u2
    @params = { :id => allBets[0].id }
    get receive_bet_path(@params)
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[2].amount)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #cancel the other bet, balance in escrow should decrease for @u1
    @params = { :id => allBets[2].id }
    get cancel_bet_path(@params)

    sign_out @u2
    sign_in @u1
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #the Away team wins in this game
    allBets = Bet.all

    if (allBets[0].away_money_line > 0.0)
      @winning_amount = (allBets[0].amount / 100.0) * allBets[0].away_money_line
    else
      @winning_amount = (allBets[0].amount / (-allBets[0].away_money_line)) * 100.0
    end

    #update the time of the bet
    @odd1.update(date: "12:10 ET 11/13/2022")
    # update u1 and u2 bets
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    @params = { :id => @u2.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    allUsers = User.all
    expect(allUsers[0].actualBalance).to eq(originalBal_u1 + @winning_amount)
    expect(allUsers[1].actualBalance).to eq(originalBal_u2 - allBets[0].amount)
  end

  it "NFL should be able to make a bet and user 2 wins" do
    originalBal_u1 = 1000
    originalBal_u2 = 2000
    dummy_game = [{ "id" => "5215e0df660ce32c023f3bbf29bf9c76", "sport_key" => "icehockey_nhl", "sport_title" => "NHL", "commence_time" => "2022-12-21T03:30:00Z", "completed" => false, "home_team" => "Los Angeles Kings", "away_team" => "Anaheim Ducks", "scores" => nil, "last_update" => nil }]
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: originalBal_u1)
    @u1.skip_confirmation!
    @u1.save!
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1', actualBalance: originalBal_u2)
    @u2.skip_confirmation!
    @u2.save!
    admin_user = User.create!(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    admin_user.skip_confirmation!
    admin_user.save!
    sign_in @u1
    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")
    @odd1 = Odd.create!(home_team_name: 'NYK',
                        away_team_name: 'OKC',
                        home_money_line: -210,
                        away_money_line: 175,
                        date: "12:10 ET 11/13/2023",
                        league: "NFL")

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams = { :home_team_name => @odd1.home_team_name,
                   :away_team_name => @odd1.away_team_name,
                   :home_money_line => @odd1.home_money_line,
                   :date => @odd1.date,
                   :away_money_line => @odd1.away_money_line,
                   :user_one_name => @u1.name,
                   :betting_on => "Home Team",
                   :user_two_name => @u2.name,
                   :amount => 125,
                   :user_id_one => @u1.id,
                   :user_id_two => @u2.id,
                   :status => "proposed",
                   :league => "NFL" }

    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams[:amount] = 300
    @betparams[:betting_on] = "Home Team"
    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @betparams[:amount] = 175
    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    expect(allBets.length()).to eq(3)

    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[1].amount + allBets[2].amount)
    expect(allUsers[0].actualBalance).to eq(@u1.actualBalance)
    expect(allUsers[1].balanceInEscrow).to eq(0)
    expect(allUsers[1].actualBalance).to eq(@u2.actualBalance)

    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    #cancel the second bet PROPOSED bet, escrow balance should reset
    @params = { :id => allBets[1].id }
    get cancel_bet_path(@params)

    allBets = Bet.all
    expect(allBets.length()).to eq(3)
    expect(allBets[1].status).to eq("cancelled")
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[2].amount)
    expect(allUsers[1].balanceInEscrow).to eq(0)

    #sign in as @u2
    sign_out @u1
    sign_in @u2

    #accept the bet, balance in escrow should increase for @u2
    @params = { :id => allBets[0].id }
    get receive_bet_path(@params)
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[2].amount)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #cancel the other bet, balance in escrow should decrease for @u1
    @params = { :id => allBets[2].id }
    get cancel_bet_path(@params)

    sign_out @u2
    sign_in @u1
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #the Away team wins in this game
    allBets = Bet.all
    if (allBets[0].away_money_line > 0.0)
      @winning_amount = (allBets[0].amount / 100.0) * allBets[0].away_money_line
    else
      @winning_amount = (allBets[0].amount / (-allBets[0].away_money_line)) * 100.0
    end

    #update the time of the bet
    @odd1.update(date: "12:10 ET 11/13/2022")
    # update u1 and u2 bets
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    @params = { :id => @u2.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    #update the time of the bet
    @odd1.update(date: "12:10 ET 11/13/2022")
    # update u1 and u2 bets
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    @params = { :id => @u2.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    allUsers = User.all

    expect(allUsers[0].actualBalance).to eq(originalBal_u1 - allBets[0].amount)
    expect(allUsers[1].actualBalance).to eq(originalBal_u2 + @winning_amount)
  end

  it "NFL should be able to make a bet and user 2 wins" do
    originalBal_u1 = 1000
    originalBal_u2 = 2000
    dummy_game = [{ "id" => "5215e0df660ce32c023f3bbf29bf9c76", "sport_key" => "icehockey_nhl", "sport_title" => "NHL", "commence_time" => "2022-12-21T03:30:00Z", "completed" => false, "home_team" => "Los Angeles Kings", "away_team" => "Anaheim Ducks", "scores" => nil, "last_update" => nil }]
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: originalBal_u1)
    @u1.skip_confirmation!
    @u1.save!
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1', actualBalance: originalBal_u2)
    @u2.skip_confirmation!
    @u2.save!
    admin_user = User.create!(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    admin_user.skip_confirmation!
    admin_user.save!
    sign_in @u1
    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")
    @odd1 = Odd.create!(home_team_name: 'NYK',
                        away_team_name: 'OKC',
                        home_money_line: -210,
                        away_money_line: 175,
                        date: "12:10 ET 11/13/2023",
                        league: "NFL")

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams = { :home_team_name => @odd1.home_team_name,
                   :away_team_name => @odd1.away_team_name,
                   :home_money_line => @odd1.home_money_line,
                   :date => @odd1.date,
                   :away_money_line => @odd1.away_money_line,
                   :user_one_name => @u1.name,
                   :betting_on => "Home Team",
                   :user_two_name => @u2.name,
                   :amount => 125,
                   :user_id_one => @u1.id,
                   :user_id_two => @u2.id,
                   :status => "proposed",
                   :league => "NFL" }

    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    expect(allBets.length()).to eq(1)

    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount)
    expect(allUsers[0].actualBalance).to eq(@u1.actualBalance)
    expect(allUsers[1].balanceInEscrow).to eq(0)
    expect(allUsers[1].actualBalance).to eq(@u2.actualBalance)

    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    #sign in as @u2
    sign_out @u1
    sign_in @u2

    #accept the bet, balance in escrow should increase for @u2
    @params = { :id => allBets[0].id }
    get receive_bet_path(@params)
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #cancel the confirmed bet, balance in escrow should decrease for @u1
    @params = { :id => allBets[0].id }
    get cancel_bet_path(@params)

    sign_out @u2
    sign_in @u1
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    # expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

  end

  it "NFL time change path" do
    originalBal_u1 = 1000
    originalBal_u2 = 2000
    dummy_game = [{ "id" => "5215e0df660ce32c023f3bbf29bf9c76", "sport_key" => "icehockey_nhl", "sport_title" => "NHL", "commence_time" => "2022-12-21T03:30:00Z", "completed" => false, "home_team" => "Los Angeles Kings", "away_team" => "Anaheim Ducks", "scores" => nil, "last_update" => nil }]
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: originalBal_u1)
    @u1.skip_confirmation!
    @u1.save!
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1', actualBalance: originalBal_u2)
    @u2.skip_confirmation!
    @u2.save!
    admin_user = User.create!(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    admin_user.skip_confirmation!
    admin_user.save!
    sign_in @u1
    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")
    @odd1 = Odd.create!(home_team_name: 'NYK',
                        away_team_name: 'OKC',
                        home_money_line: -210,
                        away_money_line: 175,
                        date: "12:10 ET 11/13/2023",
                        league: "NFL")

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams = { :home_team_name => @odd1.home_team_name,
                   :away_team_name => @odd1.away_team_name,
                   :home_money_line => @odd1.home_money_line,
                   :date => @odd1.date,
                   :away_money_line => @odd1.away_money_line,
                   :user_one_name => @u1.name,
                   :betting_on => "Home Team",
                   :user_two_name => @u2.name,
                   :amount => 125,
                   :user_id_one => @u1.id,
                   :user_id_two => @u2.id,
                   :status => "confirmed",
                   :league => "NFL" }

    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    expect(allBets.length()).to eq(1)

    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount)
    expect(allUsers[0].actualBalance).to eq(@u1.actualBalance)
    expect(allUsers[1].balanceInEscrow).to eq(0)
    expect(allUsers[1].actualBalance).to eq(@u2.actualBalance)

    @params = { :id => @u1.name, :fakedata => true, :forcetimeupdatefortest => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
  end

  it "NHL should be able to make a bet and user 1 wins" do
    originalBal_u1 = 1000
    originalBal_u2 = 2000
    dummy_game = [{ "id" => "5215e0df660ce32c023f3bbf29bf9c76", "sport_key" => "icehockey_nhl", "sport_title" => "NHL", "commence_time" => "2022-12-21T03:30:00Z", "completed" => false, "home_team" => "Los Angeles Kings", "away_team" => "Anaheim Ducks", "scores" => nil, "last_update" => nil }]
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: originalBal_u1)
    @u1.skip_confirmation!
    @u1.save!
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1', actualBalance: originalBal_u2)
    @u2.skip_confirmation!
    @u2.save!
    admin_user = User.create!(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    admin_user.skip_confirmation!
    admin_user.save!
    sign_in @u1
    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")
    @odd1 = Odd.create!(home_team_name: 'NYK',
                        away_team_name: 'OKC',
                        home_money_line: -210,
                        away_money_line: 175,
                        date: "12:10 ET 11/13/2023",
                        league: "NHL")

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams = { :home_team_name => @odd1.home_team_name,
                   :away_team_name => @odd1.away_team_name,
                   :home_money_line => @odd1.home_money_line,
                   :date => @odd1.date,
                   :away_money_line => @odd1.away_money_line,
                   :user_one_name => @u1.name,
                   :betting_on => "Away Team",
                   :user_two_name => @u2.name,
                   :amount => 125,
                   :user_id_one => @u1.id,
                   :user_id_two => @u2.id,
                   :status => "proposed",
                   :league => "NHL" }

    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams[:amount] = 300
    @betparams[:betting_on] = "Home Team"
    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @betparams[:amount] = 175
    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    expect(allBets.length()).to eq(3)

    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[1].amount + allBets[2].amount)
    expect(allUsers[0].actualBalance).to eq(@u1.actualBalance)
    expect(allUsers[1].balanceInEscrow).to eq(0)
    expect(allUsers[1].actualBalance).to eq(@u2.actualBalance)

    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    #cancel the second bet PROPOSED bet, escrow balance should reset
    @params = { :id => allBets[1].id }
    get cancel_bet_path(@params)

    allBets = Bet.all
    expect(allBets.length()).to eq(3)
    expect(allBets[1].status).to eq("cancelled")
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[2].amount)
    expect(allUsers[1].balanceInEscrow).to eq(0)

    #sign in as @u2
    sign_out @u1
    sign_in @u2

    #accept the bet, balance in escrow should increase for @u2
    @params = { :id => allBets[0].id }
    get receive_bet_path(@params)
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[2].amount)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #cancel the other bet, balance in escrow should decrease for @u1
    @params = { :id => allBets[2].id }
    get cancel_bet_path(@params)

    sign_out @u2
    sign_in @u1
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #the Away team wins in this game
    allBets = Bet.all

    if (allBets[0].away_money_line > 0.0)
      @winning_amount = (allBets[0].amount / 100.0) * allBets[0].away_money_line
    else
      @winning_amount = (allBets[0].amount / (-allBets[0].away_money_line)) * 100.0
    end

    #update the time of the bet
    @odd1.update(date: "12:10 ET 11/13/2022")
    # update u1 and u2 bets
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    @params = { :id => @u2.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    allUsers = User.all
    expect(allUsers[0].actualBalance).to eq(originalBal_u1 + @winning_amount)
    expect(allUsers[1].actualBalance).to eq(originalBal_u2 - allBets[0].amount)
  end

  it "NHL should be able to make a bet and user 2 wins" do
    originalBal_u1 = 1000
    originalBal_u2 = 2000
    dummy_game = [{ "id" => "5215e0df660ce32c023f3bbf29bf9c76", "sport_key" => "icehockey_nhl", "sport_title" => "NHL", "commence_time" => "2022-12-21T03:30:00Z", "completed" => false, "home_team" => "Los Angeles Kings", "away_team" => "Anaheim Ducks", "scores" => nil, "last_update" => nil }]
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: originalBal_u1)
    @u1.skip_confirmation!
    @u1.save!
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1', actualBalance: originalBal_u2)
    @u2.skip_confirmation!
    @u2.save!
    admin_user = User.create!(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    admin_user.skip_confirmation!
    admin_user.save!
    sign_in @u1
    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")
    @odd1 = Odd.create!(home_team_name: 'NYK',
                        away_team_name: 'OKC',
                        home_money_line: -210,
                        away_money_line: 175,
                        date: "12:10 ET 11/13/2023",
                        league: "NHL")

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams = { :home_team_name => @odd1.home_team_name,
                   :away_team_name => @odd1.away_team_name,
                   :home_money_line => @odd1.home_money_line,
                   :date => @odd1.date,
                   :away_money_line => @odd1.away_money_line,
                   :user_one_name => @u1.name,
                   :betting_on => "Home Team",
                   :user_two_name => @u2.name,
                   :amount => 125,
                   :user_id_one => @u1.id,
                   :user_id_two => @u2.id,
                   :status => "proposed",
                   :league => "NHL" }

    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams[:amount] = 300
    @betparams[:betting_on] = "Home Team"
    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @betparams[:amount] = 175
    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    expect(allBets.length()).to eq(3)

    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[1].amount + allBets[2].amount)
    expect(allUsers[0].actualBalance).to eq(@u1.actualBalance)
    expect(allUsers[1].balanceInEscrow).to eq(0)
    expect(allUsers[1].actualBalance).to eq(@u2.actualBalance)

    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    #cancel the second bet PROPOSED bet, escrow balance should reset
    @params = { :id => allBets[1].id }
    get cancel_bet_path(@params)

    allBets = Bet.all
    expect(allBets.length()).to eq(3)
    expect(allBets[1].status).to eq("cancelled")
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[2].amount)
    expect(allUsers[1].balanceInEscrow).to eq(0)

    #sign in as @u2
    sign_out @u1
    sign_in @u2

    #accept the bet, balance in escrow should increase for @u2
    @params = { :id => allBets[0].id }
    get receive_bet_path(@params)
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount + allBets[2].amount)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #cancel the other bet, balance in escrow should decrease for @u1
    @params = { :id => allBets[2].id }
    get cancel_bet_path(@params)

    sign_out @u2
    sign_in @u1
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #the Away team wins in this game
    allBets = Bet.all
    if (allBets[0].away_money_line > 0.0)
      @winning_amount = (allBets[0].amount / 100.0) * allBets[0].away_money_line
    else
      @winning_amount = (allBets[0].amount / (-allBets[0].away_money_line)) * 100.0
    end

    #update the time of the bet
    @odd1.update(date: "12:10 ET 11/13/2022")
    # update u1 and u2 bets
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    @params = { :id => @u2.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    #update the time of the bet
    @odd1.update(date: "12:10 ET 11/13/2022")
    # update u1 and u2 bets
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    @params = { :id => @u2.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    allUsers = User.all

    expect(allUsers[0].actualBalance).to eq(originalBal_u1 - allBets[0].amount)
    expect(allUsers[1].actualBalance).to eq(originalBal_u2 + @winning_amount)
  end

  it "NHL should be able to make a bet and user 2 wins" do
    originalBal_u1 = 1000
    originalBal_u2 = 2000
    dummy_game = [{ "id" => "5215e0df660ce32c023f3bbf29bf9c76", "sport_key" => "icehockey_nhl", "sport_title" => "NHL", "commence_time" => "2022-12-21T03:30:00Z", "completed" => false, "home_team" => "Los Angeles Kings", "away_team" => "Anaheim Ducks", "scores" => nil, "last_update" => nil }]
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: originalBal_u1)
    @u1.skip_confirmation!
    @u1.save!
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1', actualBalance: originalBal_u2)
    @u2.skip_confirmation!
    @u2.save!
    admin_user = User.create!(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    admin_user.skip_confirmation!
    admin_user.save!
    sign_in @u1
    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")
    @odd1 = Odd.create!(home_team_name: 'NYK',
                        away_team_name: 'OKC',
                        home_money_line: -210,
                        away_money_line: 175,
                        date: "12:10 ET 11/13/2023",
                        league: "NHL")

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams = { :home_team_name => @odd1.home_team_name,
                   :away_team_name => @odd1.away_team_name,
                   :home_money_line => @odd1.home_money_line,
                   :date => @odd1.date,
                   :away_money_line => @odd1.away_money_line,
                   :user_one_name => @u1.name,
                   :betting_on => "Home Team",
                   :user_two_name => @u2.name,
                   :amount => 125,
                   :user_id_one => @u1.id,
                   :user_id_two => @u2.id,
                   :status => "proposed",
                   :league => "NHL" }

    @params = { :bet => @betparams }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    expect(allBets.length()).to eq(1)

    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount)
    expect(allUsers[0].actualBalance).to eq(@u1.actualBalance)
    expect(allUsers[1].balanceInEscrow).to eq(0)
    expect(allUsers[1].actualBalance).to eq(@u2.actualBalance)

    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)

    #sign in as @u2
    sign_out @u1
    sign_in @u2

    #accept the bet, balance in escrow should increase for @u2
    @params = { :id => allBets[0].id }
    get receive_bet_path(@params)
    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

    #cancel the confirmed bet, balance in escrow should decrease for @u1
    @params = { :id => allBets[0].id }
    get cancel_bet_path(@params)

    sign_out @u2
    sign_in @u1
    @params = { :id => @u1.name, :fakedata => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
    # expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount)
    expect(allUsers[1].balanceInEscrow).to eq(allBets[0].amount)

  end

  it "NHL time change path" do
    originalBal_u1 = 1000
    originalBal_u2 = 2000
    dummy_game = [{ "id" => "5215e0df660ce32c023f3bbf29bf9c76", "sport_key" => "icehockey_nhl", "sport_title" => "NHL", "commence_time" => "2022-12-21T03:30:00Z", "completed" => false, "home_team" => "Los Angeles Kings", "away_team" => "Anaheim Ducks", "scores" => nil, "last_update" => nil }]
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: originalBal_u1)
    @u1.skip_confirmation!
    @u1.save!
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1', actualBalance: originalBal_u2)
    @u2.skip_confirmation!
    @u2.save!
    admin_user = User.create!(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    admin_user.skip_confirmation!
    admin_user.save!
    sign_in @u1
    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")
    @odd1 = Odd.create!(home_team_name: 'NYK',
                        away_team_name: 'OKC',
                        home_money_line: -210,
                        away_money_line: 175,
                        date: "12:10 ET 11/13/2023",
                        league: "NHL")

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams = { :home_team_name => @odd1.home_team_name,
                   :away_team_name => @odd1.away_team_name,
                   :home_money_line => @odd1.home_money_line,
                   :date => @odd1.date,
                   :away_money_line => @odd1.away_money_line,
                   :user_one_name => @u1.name,
                   :betting_on => "Home Team",
                   :user_two_name => @u2.name,
                   :amount => 125,
                   :user_id_one => @u1.id,
                   :user_id_two => @u2.id,
                   :status => "confirmed",
                   :league => "NHL" }

    @params = { :bet => @betparams, :forcetimeupdatefortest => true }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id, :forcetimeupdatefortest => true }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    expect(allBets.length()).to eq(1)

    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount)
    expect(allUsers[0].actualBalance).to eq(@u1.actualBalance)
    expect(allUsers[1].balanceInEscrow).to eq(0)
    expect(allUsers[1].actualBalance).to eq(@u2.actualBalance)

    @params = { :id => @u1.name, :fakedata => true, :forcetimeupdatefortest => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
  end

  it "NHL time change path for proposed bet that is too late" do
    originalBal_u1 = 1000
    originalBal_u2 = 2000
    dummy_game = [{ "id" => "5215e0df660ce32c023f3bbf29bf9c76", "sport_key" => "icehockey_nhl", "sport_title" => "NHL", "commence_time" => "2022-12-21T03:30:00Z", "completed" => false, "home_team" => "Los Angeles Kings", "away_team" => "Anaheim Ducks", "scores" => nil, "last_update" => nil }]
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: originalBal_u1)
    @u1.skip_confirmation!
    @u1.save!
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1', actualBalance: originalBal_u2)
    @u2.skip_confirmation!
    @u2.save!
    admin_user = User.create!(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    admin_user.skip_confirmation!
    admin_user.save!
    sign_in @u1
    @follow = Follow.create!("followable_type": "User",
                             "followable_id": @u1.id,
                             "follower_type": "User",
                             "follower_id": @u2.id,
                             "created_at": "2022-11-01 20:58:38.408190",
                             "updated_at": "2022-11-01 20:58:38.408190")
    @odd1 = Odd.create!(home_team_name: 'NYK',
                        away_team_name: 'OKC',
                        home_money_line: -210,
                        away_money_line: 175,
                        date: "12:10 ET 11/13/2023",
                        league: "NHL")

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    @betparams = { :home_team_name => @odd1.home_team_name,
                   :away_team_name => @odd1.away_team_name,
                   :home_money_line => @odd1.home_money_line,
                   :date => @odd1.date,
                   :away_money_line => @odd1.away_money_line,
                   :user_one_name => @u1.name,
                   :betting_on => "Home Team",
                   :user_two_name => @u2.name,
                   :amount => 125,
                   :user_id_one => @u1.id,
                   :user_id_two => @u2.id,
                   :status => "proposed",
                   :league => "NHL" }

    @params = { :bet => @betparams, :forcetimeupdatefortest => true }
    result = post bets_path(@params)
    expect(result).to eq(200)

    @params = { :id => @odd1.id, :amount => -1, :friend_id => @u2.id, :game => @odd1.id, :forcetimeupdatefortest => true }
    result = get placebet_bet_path(@params)
    expect(result).to eq(200)

    allBets = Bet.all
    expect(allBets.length()).to eq(1)

    allUsers = User.all
    expect(allUsers[0].balanceInEscrow).to eq(allBets[0].amount)
    expect(allUsers[0].actualBalance).to eq(@u1.actualBalance)
    expect(allUsers[1].balanceInEscrow).to eq(0)
    expect(allUsers[1].actualBalance).to eq(@u2.actualBalance)

    @params = { :id => @u1.name, :fakedata => true, :forcetimeupdatefortest => true, :dummy_game => dummy_game }
    result = get allbets_home_page_path(@params)
    expect(result).to eq(200)
  end
end



