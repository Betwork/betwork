require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require 'date'

class OddsController < ApplicationController
  before_action :set_user

  def index

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

    team_names_NFL = {
      'ARZ' => 'Arizona Cardinals',
      'ATL' => 'Atlanta Falcons',
      'BLT' => 'Baltimore Ravens',
      'BUF' => 'Buffalo Bills',
      'CAR' => 'Carolina Panthers',
      'CHI' => 'Chicago Bears',
      'CIN' => 'Cincinnati Bengals',
      'CLV' => 'Cleveland Browns',
      'DAL' => 'Dallas Cowboys',
      'DEN' => 'Denver Broncos',
      'DET' => 'Detroit Lions',
      'GB' => 'Green Bay Packers',
      'HST' => 'Houston Texans',
      'IND' => 'Indianapolis Colts',
      'JAX' => 'Jacksonville Jaguars',
      'KC' => 'Kansas City Chiefs',
      'LV' => 'Las Vegas Raiders',
      'LAC' => 'Los Angeles Chargers',
      'LA' => 'Los Angeles Rams',
      'MIA' => 'Miami Dolphins',
      'MIN' => 'Minnesota Vikings',
      'NE' => 'New England Patriots',
      'NO' => 'New Orleans Saints',
      'NYG' => 'New York Giants',
      'NYJ' => 'New York Jets',
      'PHI' => 'Philadelphia Eagles',
      'PIT' => 'Pittsburgh Steelers',
      'SF' => 'San Francisco 49ers',
      'SEA' => 'Seattle Seahawks',
      'TB' => 'Tampa Bay Buccaneers',
      'TEN' => 'Tennessee Titans',
      'WAS' => 'Washington Commanders'
    }

    # puts "execute index"
    # puts params
    @odds = Odd.all
    Odd.delete_all
    old_odd = Odd.create!(
      "home_team_name": "New Orleans Pelicans",
      "away_team_name": "Phoenix Suns",
      "home_money_line": -210,
      "away_money_line": 175,
      "date": "20:40 ET 12/11/2022",
      "toolate": false,
      "league": "NBA"
    )
    old_odd.save

    date_string = '8:10 ET 11/26/2022'
    date_object = DateTime.strptime(date_string, '%H:%M %z %m/%d/%Y')
    if (date_object.hour < 12)
      date_object = date_object + (12/24.0)
    end
    early = date_object - (2/24.0)
    current_time = DateTime.now
    toolate_boolean = current_time > early

    old_odd_expired = Odd.create!(
      "home_team_name": team_names["SAS"],
      "away_team_name": team_names["LAL"],
      "home_money_line": 120,
      "away_money_line": -140,
      "date": "8:10 ET 11/26/2022",
      "toolate": toolate_boolean,
      "league": "NBA"
    )
    old_odd_expired.save

    old_odd_unexpired = Odd.create!(
      "home_team_name": team_names["WAS"],
      "away_team_name": team_names["DAL"],
      "home_money_line": 120,
      "away_money_line": -130,
      "date": "7:00 ET 11/11/2022",
      "toolate": false,
      "league": "NBA"
    )
    old_odd_unexpired.save

    odds = find_nba_odds()
    if odds != nil
      odds.each do |odd|

        # checking if the odd is non-Null
        if (!odd['home_team'].nil? and
          !odd['away_team'].nil?)

          # extracting the home and away team names
          home_team_name = odd['home_team']
          away_team_name = odd['away_team']

          # getting the start time of the game in UTC
          date_string = odd['commence_time']
          date_object_utc = DateTime.strptime(date_string, '%Y-%m-%dT%H:%M:%s')

          # offsetting the time to EST
          eastern_offset = Rational(-5, 24)
          date_object_eastern = date_object_utc.new_offset(eastern_offset)
          date_string_eastern = date_object_eastern.strftime('%H:%M ET %m/%d/%Y')

          # comparing current time in EST to 2hrs before start time of game in eastern
          early_time_eastern = date_object_eastern - (2/24.0)
          current_time = DateTime.now
          current_time_eastern = current_time.new_offset(eastern_offset)
          toolate_boolean = current_time_eastern > early_time_eastern

          # extracting the home and away team odds
          if (odd['bookmakers'][0]['markets'][0]['outcomes'][0]['name'] == home_team_name)
            home_team_odds = odd['bookmakers'][0]['markets'][0]['outcomes'][0]['price']
            away_team_odds = odd['bookmakers'][0]['markets'][0]['outcomes'][1]['price']
          else
            home_team_odds = odd['bookmakers'][0]['markets'][0]['outcomes'][1]['price']
            away_team_odds = odd['bookmakers'][0]['markets'][0]['outcomes'][0]['price']
          end

          new_odd = Odd.create!(
            "home_team_name": home_team_name,
            "away_team_name": away_team_name,
            "home_money_line": home_team_odds,
            "away_money_line": away_team_odds,
            "date": date_string_eastern,
            "toolate": toolate_boolean,
            "league": "NBA"
          )
          new_odd.save
        end
      end
    end

    odds = find_nfl_odds()
    if odds != nil
      odds.each do |odd|

        # checking if the odd is non-Null
        if (!odd['home_team'].nil? and
          !odd['away_team'].nil?)

          # extracting the home and away team names
          home_team_name = odd['home_team']
          away_team_name = odd['away_team']

          # getting the start time of the game in UTC
          date_string = odd['commence_time']
          date_object_utc = DateTime.strptime(date_string, '%Y-%m-%dT%H:%M:%s')

          # offsetting the time to EST
          eastern_offset = Rational(-5, 24)
          date_object_eastern = date_object_utc.new_offset(eastern_offset)
          date_string_eastern = date_object_eastern.strftime('%H:%M ET %m/%d/%Y')

          # comparing current time in EST to 2hrs before start time of game in eastern
          early_time_eastern = date_object_eastern - (2/24.0)
          current_time = DateTime.now
          current_time_eastern = current_time.new_offset(eastern_offset)
          toolate_boolean = current_time_eastern > early_time_eastern

          # extracting the home and away team odds
          if (odd['bookmakers'][0]['markets'][0]['outcomes'][0]['name'] == home_team_name)
            home_team_odds = odd['bookmakers'][0]['markets'][0]['outcomes'][0]['price']
            away_team_odds = odd['bookmakers'][0]['markets'][0]['outcomes'][1]['price']
          else
            home_team_odds = odd['bookmakers'][0]['markets'][0]['outcomes'][1]['price']
            away_team_odds = odd['bookmakers'][0]['markets'][0]['outcomes'][0]['price']
          end

          new_odd = Odd.create!(
            "home_team_name": home_team_name,
            "away_team_name": away_team_name,
            "home_money_line": home_team_odds,
            "away_money_line": away_team_odds,
            "date": date_string_eastern,
            "toolate": toolate_boolean,
            "league": "NFL"
          )
          new_odd.save
        end
      end
    end

    odds = find_nhl_odds()
    if odds != nil
      odds.each do |odd|

        # checking if the odd is non-Null
        if (!odd['home_team'].nil? and
          !odd['away_team'].nil?)

          # extracting the home and away team names
          home_team_name = odd['home_team']
          away_team_name = odd['away_team']

          # getting the start time of the game in UTC
          date_string = odd['commence_time']
          date_object_utc = DateTime.strptime(date_string, '%Y-%m-%dT%H:%M:%s')

          # offsetting the time to EST
          eastern_offset = Rational(-5, 24)
          date_object_eastern = date_object_utc.new_offset(eastern_offset)
          date_string_eastern = date_object_eastern.strftime('%H:%M ET %m/%d/%Y')

          # comparing current time in EST to 2hrs before start time of game in eastern
          early_time_eastern = date_object_eastern - (2/24.0)
          current_time = DateTime.now
          current_time_eastern = current_time.new_offset(eastern_offset)
          toolate_boolean = current_time_eastern > early_time_eastern

          # extracting the home and away team odds
          if (odd['bookmakers'][0]['markets'][0]['outcomes'][0]['name'] == home_team_name)
            home_team_odds = odd['bookmakers'][0]['markets'][0]['outcomes'][0]['price']
            away_team_odds = odd['bookmakers'][0]['markets'][0]['outcomes'][1]['price']
          else
            home_team_odds = odd['bookmakers'][0]['markets'][0]['outcomes'][1]['price']
            away_team_odds = odd['bookmakers'][0]['markets'][0]['outcomes'][0]['price']
          end

          new_odd = Odd.create!(
            "home_team_name": home_team_name,
            "away_team_name": away_team_name,
            "home_money_line": home_team_odds,
            "away_money_line": away_team_odds,
            "date": date_string_eastern,
            "toolate": toolate_boolean,
            "league": "NHL"
          )
          new_odd.save
        end
      end
    end

    @odds = Odd.all
  end

  def friends
    # puts "execute friends"
    # puts params
    @friends = @user.following_users.paginate(page: params[:page])
    @game = Odd.find params[:id]
    @amount = params[:amount].nil? ? -1 : params[:amount]
  end

  def show
    # puts "show"
    @odds = Odd.all
  end

  private

  # def request_api(url)
  #   puts "request_api"
  #   response = Excon.get(
  #     url,
  #     headers: {
  #       'X-RapidAPI-Host' => URI.parse(url).host,
  #       #'X-RapidAPI-Key' => "0922e8a07dmsh4cacadace93e259p191ebajsn446e95a439bc"
  #       'X-RapidAPI-Key' => ENV.fetch('RAPIDAPI_API_KEY')
  #     }
  #   )
  #
  #   return nil if response.status != 200
  #
  #   puts JSON.parse(response.body)
  #   JSON.parse(response.body)
  # end

  def find_nba_odds()
    # puts "find_nba_odds"
    # request_api('https://sports-data3.p.rapidapi.com/nba')
    url = URI("https://odds.p.rapidapi.com/v4/sports/basketball_nba/odds?regions=us&oddsFormat=american&markets=h2h&dateFormat=iso")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = 'b75f06b51amshedbb7bbb363591fp1d8c49jsnea0e9ea45d3b'
    request["X-RapidAPI-Host"] = 'odds.p.rapidapi.com'

    response = http.request(request)
    # puts JSON.parse(response.read_body)
    begin
      result = JSON.parse(response.read_body)
      return result
    rescue
      puts "API IS Down"
    end
  end

  def find_nfl_odds()
    # puts "find_nba_odds"
    # request_api('https://sports-data3.p.rapidapi.com/nba')
    url = URI("https://odds.p.rapidapi.com/v4/sports/americanfootball_nfl/odds?regions=us&oddsFormat=american&markets=h2h&dateFormat=iso")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = 'b75f06b51amshedbb7bbb363591fp1d8c49jsnea0e9ea45d3b'
    request["X-RapidAPI-Host"] = 'odds.p.rapidapi.com'

    response = http.request(request)
    # puts JSON.parse(response.read_body)
    begin
      result = JSON.parse(response.read_body)
      return result
    rescue
      puts "API IS Down"
    end
  end

  def find_nhl_odds()
    # puts "find_nba_odds"
    # request_api('https://sports-data3.p.rapidapi.com/nba')
    url = URI("https://odds.p.rapidapi.com/v4/sports/icehockey_nhl/odds?regions=us&oddsFormat=american&markets=h2h&dateFormat=iso")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = 'b75f06b51amshedbb7bbb363591fp1d8c49jsnea0e9ea45d3b'
    request["X-RapidAPI-Host"] = 'odds.p.rapidapi.com'

    response = http.request(request)
    # puts JSON.parse(response.read_body)
    begin
      result = JSON.parse(response.read_body)
      return result
    rescue
      puts "API IS Down"
    end
  end

  # def user_params
  #   puts "user_params"
  #   params.require(:user).permit(:name, :about, :avatar, :cover,
  #                                :sex, :dob, :location, :phone_number)
  # end
  #
  # def check_ownership
  #   puts "check_ownership"
  #   redirect_to current_user, notice: 'Not Authorized' unless @user == current_user
  # end

  def set_user
    # puts "set_user"
    @user = current_user
    render_404 and return unless @user
  end
end