# Copyright (c) 2015, @sudharti(Sudharsanan Muralidharan)
# Socify is an Open source Social network written in Ruby on Rails This file is licensed
# under GNU GPL v2 or later. See the LICENSE.

class HomeController < ApplicationController
  before_action :set_user, except: :front
  before_action :admin_user
  respond_to :html, :js

  def allbets_home_page
    #puts "allbets"
    # setting a hash that maps team abbreviations to team names
    # used later in string comparisons

    # get all the bets of the current user
    @user_bets = Bet.get_by_userid(current_user.id)
    fakedata = params[:fakedata]
    forcetimeupdatefortest = params[:forcetimeupdatefortest]
    dummy_game = params[:dummy_game]

    # send the API request for NBA games
    url = URI("https://odds.p.rapidapi.com/v4/sports/basketball_nba/scores?daysFrom=3")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = 'b75f06b51amshedbb7bbb363591fp1d8c49jsnea0e9ea45d3b'
    request["X-RapidAPI-Host"] = 'odds.p.rapidapi.com'

    response = http.request(request)
    nba_games = JSON.parse(response.read_body)
    if fakedata
      # nba_games = dummy_game
    end

    # send the API request for NFL games
    url = URI("https://odds.p.rapidapi.com/v4/sports/americanfootball_nfl/scores?daysFrom=3")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = 'b75f06b51amshedbb7bbb363591fp1d8c49jsnea0e9ea45d3b'
    request["X-RapidAPI-Host"] = 'odds.p.rapidapi.com'

    response = http.request(request)
    nfl_games = JSON.parse(response.read_body)
    if fakedata
      # nfl_games = dummy_game
    end

    # send the API request for NHL games
    url = URI("https://odds.p.rapidapi.com/v4/sports/icehockey_nhl/scores?daysFrom=3")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = 'b75f06b51amshedbb7bbb363591fp1d8c49jsnea0e9ea45d3b'
    request["X-RapidAPI-Host"] = 'odds.p.rapidapi.com'

    response = http.request(request)
    nhl_games = JSON.parse(response.read_body)
    if fakedata
      # nhl_games = dummy_game
    end

    # for each bet
    @user_bets.each do |bet|
      # puts "reached 1"
      # only proceed with confirmed bets
      if (bet.status == 'confirmed')
        # puts "reached 2"

        # get the date of the bet in the right format
        date_string_bet = Date.strptime(bet.date, '%H:%M %z %m/%d/%Y').strftime('%Y-%m-%d')

        # select the right league for the game
        if (bet.league == 'NBA')
          # for each game in the response
          # puts "reached 3"
          nba_games.each do |game|
            # puts "reached 4"
            # extract the date of the game
            date_string = game['commence_time']
            date_object_utc = DateTime.strptime(date_string, '%Y-%m-%dT%H:%M:%s')

            # offsetting the time to EST
            eastern_offset = Rational(-5, 24)
            date_object_eastern = date_object_utc.new_offset(eastern_offset)
            date_string_game = date_object_eastern.strftime('%Y-%m-%d')

            # if the game has the same teams (and date from before), proceed
            if ((bet.home_team_name == game['home_team']) && (bet.away_team_name == game['away_team']) && date_string_bet == date_string_game) || fakedata
              # puts "reached 5"
              # puts game
              # puts game['completed']
              # puts !forcetimeupdatefortest
              # puts game['completed'] && !forcetimeupdatefortest

              # if the game is finished, proceed
              if game['completed'] && !forcetimeupdatefortest
                # puts "reached 6"
                #
                # puts "made it inside here"
                #get the final scores of the game
                scores = game['scores']

                #get the scores of the home and away team
                if (scores[0]['name'] == game['home_team'])
                  home_score = scores[0]['score']
                  away_score = scores[1]['score']
                else
                  home_score = scores[1]['score']
                  away_score = scores[0]['score']
                end

                # establish whether Home or Away won
                if (home_score > away_score) && !fakedata
                  winning_team = 'Home Team'
                else
                  winning_team = 'Away Team'
                end

                # get the users of the bet
                @user_one = User.find_by(id: bet.user_id_one)
                @user_two = User.find_by(id: bet.user_id_two)

                # get the amount wagered as a float
                @amount = (bet.amount).to_f

                # figure out which odds to use for the winnings based
                # on outcome of the game
                if (winning_team == 'Home Team')
                  odds = (bet.home_money_line).to_f
                else
                  odds = (bet.away_money_line).to_f
                end

                # apply the US odds formula to calculate the winnings
                if (odds > 0.0)
                  @winning_amount = (@amount / 100.0) * odds
                else
                  @winning_amount = (@amount / (-odds)) * 100.0
                end
                # puts "actual winning amt"
                # puts @winning_amount
                # setting variables to make post
                @bet = bet
                admin_user = User.get_admin_user()

                # if user one won
                if (bet.betting_on == winning_team)

                  # increase his actual balance by the winnings
                  @user_one.decrease_balance(-@winning_amount)

                  # remove wagered amount from escrow
                  @user_one.increase_balance_in_escrow(-@amount)

                  # remove amount wagered from actual balance of user two
                  @user_two.decrease_balance(@amount)

                  # remove wagered amount from escrow
                  @user_two.increase_balance_in_escrow(-@amount)
                  #puts 'User two lost'

                  # making post that User One Won
                  content_string = create_bet_won_message_string(@user_one, @user_two, @bet)
                  test = { "content" => content_string }
                  @post = admin_user.posts.new(test)
                  @post.save
                else

                  # increase his actual balance by the winnings
                  @user_two.decrease_balance(-@winning_amount)

                  # remove wagered amount from escrow
                  @user_two.increase_balance_in_escrow(-@amount)

                  # remove amount wagered from actual balance of user two
                  @user_one.decrease_balance(@amount)

                  # remove wagered amount from escrow
                  @user_one.increase_balance_in_escrow(-@amount)
                  #puts 'User one lost'

                  # making post that User Two Won
                  content_string = create_bet_won_message_string(@user_two, @user_one, @bet)
                  test = { "content" => content_string }
                  @post = admin_user.posts.new(test)
                  @post.save
                end

                # change the status of the bet and save it
                bet.status = 'finished'
                bet.save
              else
                # extracting bet date and time
                date_string = bet['date']
                date_object_eastern = DateTime.strptime(date_string, '%H:%M %z %m/%d/%Y')

                # offsetting the time to EST
                utc_offset = Rational(0, 24)

                # comparing current time in EST to 2hrs before start time of game in eastern
                early_time_eastern = date_object_eastern - (2 / 24.0)
                current_time = DateTime.now
                current_time_utc = current_time.new_offset(utc_offset)
                current_time_eastern = current_time_utc - (5 / 24.0)
                toolate_boolean = current_time_eastern > early_time_eastern

                bet.toolate = toolate_boolean
                bet.save
              end

              # whether or not the game is finished,
              # once we have found the game, we do not
              # want to further check games of this day
              break
            end
          end
        elsif (bet.league == 'NFL')
          # for each game in the response
          # puts "nfl games"
          # puts nfl_games
          nfl_games.each do |game|

            date_string = game['commence_time']
            date_object_utc = DateTime.strptime(date_string, '%Y-%m-%dT%H:%M:%s')

            # offsetting the time to EST
            eastern_offset = Rational(-5, 24)
            date_object_eastern = date_object_utc.new_offset(eastern_offset)
            date_string_game = date_object_eastern.strftime('%Y-%m-%d')

            # if the game has the same teams (and date from before), proceed
            if ((bet.home_team_name == game['home_team']) && (bet.away_team_name == game['away_team']) && date_string_bet == date_string_game) || fakedata

              # if the game is finished, proceed
              if game['completed'] && !forcetimeupdatefortest

                #get the final scores of the game
                scores = game['scores']

                if (scores[0]['name'] == game['home_team'])
                  home_score = scores[0]['score']
                  away_score = scores[1]['score']
                else
                  home_score = scores[1]['score']
                  away_score = scores[0]['score']
                end

                # establish whether Home or Away won
                if (home_score > away_score) && !fakedata
                  winning_team = 'Home Team'
                else
                  winning_team = 'Away Team'
                end

                # get the users of the bet
                @user_one = User.find_by(id: bet.user_id_one)
                @user_two = User.find_by(id: bet.user_id_two)

                # get the amount wagered as a float
                @amount = (bet.amount).to_f

                # figure out which odds to use for the winnings based
                # on outcome of the game
                if (winning_team == 'Home Team')
                  odds = (bet.home_money_line).to_f
                else
                  odds = (bet.away_money_line).to_f
                end

                # apply the US odds formula to calculate the winnings
                if (odds > 0.0)
                  @winning_amount = (@amount / 100.0) * odds
                else
                  @winning_amount = (@amount / (-odds)) * 100.0
                end

                # setting variables to make post
                @bet = bet
                admin_user = User.get_admin_user()

                # if user one won
                if (bet.betting_on == winning_team)

                  # increase his actual balance by the winnings
                  @user_one.decrease_balance(-@winning_amount)

                  # remove wagered amount from escrow
                  @user_one.increase_balance_in_escrow(-@amount)

                  # remove amount wagered from actual balance of user two
                  @user_two.decrease_balance(@amount)

                  # remove wagered amount from escrow
                  @user_two.increase_balance_in_escrow(-@amount)
                  #puts 'User two lost'

                  # making post that User One Won
                  content_string = create_bet_won_message_string(@user_one, @user_two, @bet)
                  test = { "content" => content_string }
                  @post = admin_user.posts.new(test)
                  @post.save
                else

                  # increase his actual balance by the winnings
                  @user_two.decrease_balance(-@winning_amount)

                  # remove wagered amount from escrow
                  @user_two.increase_balance_in_escrow(-@amount)

                  # remove amount wagered from actual balance of user two
                  @user_one.decrease_balance(@amount)

                  # remove wagered amount from escrow
                  @user_one.increase_balance_in_escrow(-@amount)
                  #puts 'User one lost'

                  # making post that User Two Won
                  content_string = create_bet_won_message_string(@user_two, @user_one, @bet)
                  test = { "content" => content_string }
                  @post = admin_user.posts.new(test)
                  @post.save
                end

                # change the status of the bet and save it
                bet.status = 'finished'
                bet.save
              else
                # extracting bet date and time
                date_string = bet['date']
                date_object_eastern = DateTime.strptime(date_string, '%H:%M %z %m/%d/%Y')

                # offsetting the time to EST
                utc_offset = Rational(0, 24)

                # comparing current time in EST to 2hrs before start time of game in eastern
                early_time_eastern = date_object_eastern - (2 / 24.0)
                current_time = DateTime.now
                current_time_utc = current_time.new_offset(utc_offset)
                current_time_eastern = current_time_utc - (5 / 24.0)
                toolate_boolean = current_time_eastern > early_time_eastern

                bet.toolate = toolate_boolean
                bet.save
              end

              # whether or not the game is finished,
              # once we have found the game, we do not
              # want to further check games of this day
              break
            end
          end
        else
          nhl_games.each do |game|

            date_string = game['commence_time']
            date_object_utc = DateTime.strptime(date_string, '%Y-%m-%dT%H:%M:%s')

            # offsetting the time to EST
            eastern_offset = Rational(-5, 24)
            date_object_eastern = date_object_utc.new_offset(eastern_offset)
            date_string_game = date_object_eastern.strftime('%Y-%m-%d')

            # if the game has the same teams (and date from before), proceed
            if ((bet.home_team_name == game['home_team']) && (bet.away_team_name == game['away_team']) && date_string_bet == date_string_game) || fakedata

              # if the game is finished, proceed
              if game['completed'] && !forcetimeupdatefortest

                #get the final scores of the game
                scores = game['scores']

                if (scores[0]['name'] == game['home_team'])
                  home_score = scores[0]['score']
                  away_score = scores[1]['score']
                else
                  home_score = scores[1]['score']
                  away_score = scores[0]['score']
                end

                # establish whether Home or Away won
                if (home_score > away_score) && !fakedata
                  winning_team = 'Home Team'
                else
                  winning_team = 'Away Team'
                end

                # get the users of the bet
                @user_one = User.find_by(id: bet.user_id_one)
                @user_two = User.find_by(id: bet.user_id_two)

                # get the amount wagered as a float
                @amount = (bet.amount).to_f

                # figure out which odds to use for the winnings based
                # on outcome of the game
                if (winning_team == 'Home Team')
                  odds = (bet.home_money_line).to_f
                else
                  odds = (bet.away_money_line).to_f
                end

                # apply the US odds formula to calculate the winnings
                if (odds > 0.0)
                  @winning_amount = (@amount / 100.0) * odds
                else
                  @winning_amount = (@amount / (-odds)) * 100.0
                end

                # setting variables to make post
                @bet = bet
                admin_user = User.get_admin_user()

                # if user one won
                if (bet.betting_on == winning_team)

                  # increase his actual balance by the winnings
                  @user_one.decrease_balance(-@winning_amount)

                  # remove wagered amount from escrow
                  @user_one.increase_balance_in_escrow(-@amount)

                  # remove amount wagered from actual balance of user two
                  @user_two.decrease_balance(@amount)

                  # remove wagered amount from escrow
                  @user_two.increase_balance_in_escrow(-@amount)
                  #puts 'User two lost'

                  # making post that User One Won
                  content_string = create_bet_won_message_string(@user_one, @user_two, @bet)
                  test = { "content" => content_string }
                  @post = admin_user.posts.new(test)
                  @post.save
                else

                  # increase his actual balance by the winnings
                  @user_two.decrease_balance(-@winning_amount)

                  # remove wagered amount from escrow
                  @user_two.increase_balance_in_escrow(-@amount)

                  # remove amount wagered from actual balance of user two
                  @user_one.decrease_balance(@amount)

                  # remove wagered amount from escrow
                  @user_one.increase_balance_in_escrow(-@amount)
                  #puts 'User one lost'

                  # making post that User Two Won
                  content_string = create_bet_won_message_string(@user_two, @user_one, @bet)
                  test = { "content" => content_string }
                  @post = admin_user.posts.new(test)
                  @post.save
                end

                # change the status of the bet and save it
                bet.status = 'finished'
                bet.save
              else
                # extracting bet date and time
                date_string = bet['date']
                date_object_eastern = DateTime.strptime(date_string, '%H:%M %z %m/%d/%Y')

                # offsetting the time to EST
                utc_offset = Rational(0, 24)

                # comparing current time in EST to 2hrs before start time of game in eastern
                early_time_eastern = date_object_eastern - (2 / 24.0)
                current_time = DateTime.now
                current_time_utc = current_time.new_offset(utc_offset)
                current_time_eastern = current_time_utc - (5 / 24.0)
                toolate_boolean = current_time_eastern > early_time_eastern

                bet.toolate = toolate_boolean
                bet.save
              end

              # whether or not the game is finished,
              # once we have found the game, we do not
              # want to further check games of this day
              break
            end
          end
        end

      elsif (bet.status == 'proposed')

        # CREATING AN OLD NBA GAME

        # send the API request for NBA games
        url = URI("https://odds.p.rapidapi.com/v4/sports/basketball_nba/scores?daysFrom=3")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(url)
        request["X-RapidAPI-Key"] = 'b75f06b51amshedbb7bbb363591fp1d8c49jsnea0e9ea45d3b'
        request["X-RapidAPI-Host"] = 'odds.p.rapidapi.com'
        response = http.request(request)
        nba_games = JSON.parse(response.read_body)
        if fakedata
          nba_games = dummy_game
        end

        # team names
        nba_home_team_name = nba_games[0]['home_team']
        nba_away_team_name = nba_games[0]['away_team']

        # getting the start time of the game in UTC
        date_string = nba_games[0]['commence_time']
        date_object_utc = DateTime.strptime(date_string, '%Y-%m-%dT%H:%M:%s')

        # offsetting the time to EST
        eastern_offset = Rational(-5, 24)
        date_object_eastern = date_object_utc.new_offset(eastern_offset)
        nba_date_string_eastern = date_object_eastern.strftime('%H:%M ET %m/%d/%Y')

        # CREATING AN OLD NHL GAME

        # send the API request for NHL games
        url = URI("https://odds.p.rapidapi.com/v4/sports/icehockey_nhl/scores?daysFrom=3")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(url)
        request["X-RapidAPI-Key"] = 'b75f06b51amshedbb7bbb363591fp1d8c49jsnea0e9ea45d3b'
        request["X-RapidAPI-Host"] = 'odds.p.rapidapi.com'
        response = http.request(request)
        nhl_games = JSON.parse(response.read_body)
        if fakedata
          nhl_games = dummy_game
        end

        # team names
        nhl_home_team_name = nhl_games[0]['home_team']
        nhl_away_team_name = nhl_games[0]['away_team']

        # getting the start time of the game in UTC
        date_string = nhl_games[0]['commence_time']
        date_object_utc = DateTime.strptime(date_string, '%Y-%m-%dT%H:%M:%s')

        # offsetting the time to EST
        eastern_offset = Rational(-5, 24)
        date_object_eastern = date_object_utc.new_offset(eastern_offset)
        nhl_date_string_eastern = date_object_eastern.strftime('%H:%M ET %m/%d/%Y')

        if (not ((bet.home_team_name == nba_home_team_name) &&
          (bet.away_team_name == nba_away_team_name) &&
          (bet.date == nba_date_string_eastern)) && not((bet.home_team_name == nhl_home_team_name) &&
          (bet.away_team_name == nhl_away_team_name) &&
          (bet.date == nhl_date_string_eastern)))
          # extracting bet date and time
          date_string = bet['date']
          date_object_eastern = DateTime.strptime(date_string, '%H:%M %z %m/%d/%Y')

          # offsetting the time to EST
          utc_offset = Rational(0, 24)

          # comparing current time in EST to 2hrs before start time of game in eastern
          early_time_eastern = date_object_eastern - (2 / 24.0)
          current_time = DateTime.now
          current_time_utc = current_time.new_offset(utc_offset)
          current_time_eastern = current_time_utc - (5 / 24.0)
          toolate_boolean = current_time_eastern > early_time_eastern

          bet.toolate = toolate_boolean
          if (toolate_boolean) || forcetimeupdatefortest
            bet.status = 'cancelled'
            @original = User.find_by(id: bet.user_id_one)
            @original.increase_balance_in_escrow(-bet.amount)
          end
          bet.save
        end

      end
    end
  end

  def index
    # puts "this function is called on the home page"
    allbets_home_page
    @post = Post.new
    @friends = @user.all_following.unshift(@user)
    @activities = PublicActivity::Activity.where(owner_id: @friends).or(PublicActivity::Activity.where(owner_id: @admin_user)).order(created_at: :desc).paginate(page: params[:page], per_page: 10)
  end

  def front
    @activities = PublicActivity::Activity.joins("INNER JOIN users ON activities.owner_id = users.id").order(created_at: :desc).paginate(page: params[:page], per_page: 10)
  end

  def find_friends
    @friends = @user.all_following
    # puts "FRIENDS STUFF"
    # puts @friends.class
    @users = User.where.not(id: @friends.unshift(@user)).paginate(page: params[:page])
  end

  private

  def set_user
    @user = current_user
  end

  def admin_user
    @admin_user = User.get_admin_user()
  end
end
