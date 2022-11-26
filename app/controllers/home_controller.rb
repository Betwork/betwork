# Copyright (c) 2015, @sudharti(Sudharsanan Muralidharan)
# Socify is an Open source Social network written in Ruby on Rails This file is licensed
# under GNU GPL v2 or later. See the LICENSE.



class HomeController < ApplicationController
  before_action :set_user, except: :front
  before_action :admin_user
  respond_to :html, :js

  def allbets_home_page
    #puts "allbets_home_page"
    # setting a hash that maps team abbreviations to team names
    # used later in string comparisons
    team_names = {
      'ATL' => 'Atlanta Hawks',
      'BKN' => 'Brooklyn Nets',
      'BOS' => 'Boston Celtics',
      'CHA' => 'Charlotte Hornets',
      'CHI' => 'Chicago Bulls',
      'CLE' => 'Cleveland Cavaliers',
      'DAL' => 'Dallas Mavericks',
      'DEN' => 'Denver Nuggets',
      'DET' => 'Detroit Pistons',
      'GSW' => 'Golden State Warriors',
      'HOU' => 'Houston Rockets',
      'IND' => 'Indiana Pacers',
      'LAC' => 'Los Angeles Clippers',
      'LAL' => 'Los Angeles Lakers',
      'MEM' => 'Memphis Grizzlies',
      'MIA' => 'Miami Heat',
      'MIL' => 'Milwaukee Bucks',
      'MIN' => 'Minnesota Timberwolves',
      'NOP' => 'New Orleans Pelicans',
      'NYK' => 'New York Knicks',
      'OKC' => 'Oklahoma City Thunder',
      'ORL' => 'Orlando Magic',
      'PHI' => 'Philadelphia 76ers',
      'PHX' => 'Phoenix Suns',
      'POR' => 'Portland Trail Blazers',
      'SAC' => 'Sacramento Kings',
      'SAS' => 'San Antonio Spurs',
      'TOR' => 'Toronto Raptors',
      'UTA' => 'Utah Jazz',
      'WAS' => 'Washington Wizards'
    }

    # get all the bets of the current user
    @user_bets = Bet.get_by_userid(current_user.id)

    # for each bet
    @user_bets.each do |bet|

      # only proceed with confirmed bets
      if (bet.status == 'confirmed')

        # get the date of the game in the right format
        date_string = Date.strptime(bet.date, '%H:%M %z %m/%d/%Y').strftime('%Y-%m-%d')

        # add the date of the game to the query string
        url_without_date = "https://api-basketball.p.rapidapi.com/games?timezone=America%2FNew_York&season=2022-2023&league=12&date="
        url_with_date = url_without_date + date_string

        # send the API request
        url = URI(url_with_date)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(url)
        request["X-RapidAPI-Key"] = 'b75f06b51amshedbb7bbb363591fp1d8c49jsnea0e9ea45d3b'
        request["X-RapidAPI-Host"] = 'api-basketball.p.rapidapi.com'
        response = http.request(request)

        # parse the response
        parsed_response = JSON.parse(response.read_body)
        games_information = parsed_response['response']

        # for each game in the response
        games_information.each do |game|

          # if the game has the same teams (and date from before), proceed
          if ((team_names[bet.home_team_name] == game['teams']['home']['name']) &&
            (team_names[bet.away_team_name] == game['teams']['away']['name']))

            # if the game is finished, proceed
            if game['status']['long'] == 'Game Finished'

              #get the final scores of the game
              scores = game['scores']
              home_score = scores['home']['total']
              away_score = scores['away']['total']

              # establish whether Home or Away won
              if (home_score > away_score)
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
            end

            # whether or not the game is finished,
            # once we have found the game, we do not
            # want to further check games of this day
            break
          end
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
