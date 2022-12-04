require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require 'date'

class OddsController < ApplicationController
  before_action :set_user

  def index
    # puts "execute index"
    # puts params
    @odds = Odd.all
    Odd.delete_all
    old_odd = Odd.create!(
      "home_team_name": "NYK",
      "away_team_name": "OKC",
      "home_money_line": -210,
      "away_money_line": 175,
      "date": "12:10 ET 11/13/2022",
      "toolate": false
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
      "home_team_name": "SAS",
      "away_team_name": "LAL",
      "home_money_line": 120,
      "away_money_line": -140,
      "date": "8:10 ET 11/26/2022",
      "toolate": toolate_boolean
    )
    old_odd_expired.save

    old_odd_unexpired = Odd.create!(
      "home_team_name": "WAS",
      "away_team_name": "DAL",
      "home_money_line": 120,
      "away_money_line": -130,
      "date": "7:00 ET 11/11/2022",
      "toolate": false
    )
    old_odd_unexpired.save

    odds = find_nba_odds()
    if odds == nil 
      @odds = Odd.all
      return
    end
    odds.each do |odd|
      if (!odd['homeTeam'].nil? and
        !odd['awayTeam'].nil? and
        !odd['homeMoneyLine'].nil? and
        !odd['awayMoneyLine'].nil?)
        date_string = odd['startTime']
        date_object = DateTime.strptime(date_string, '%H:%M %z %m/%d/%Y')
        if (date_object.hour < 12)
          date_object = date_object + (12/24.0)
        end
        #early = date_object - (2/24.0)
        current_time = DateTime.now
        toolate_boolean = current_time.ctime > date_object.ctime 
        new_odd = Odd.create!(
          "home_team_name": odd['homeTeam'],
          "away_team_name": odd['awayTeam'],
          "home_money_line": odd['homeMoneyLine'],
          "away_money_line": odd['awayMoneyLine'],
          "date": odd['startTime'],
          "toolate": toolate_boolean
        )
        new_odd.save
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
    url = URI("https://sports-data3.p.rapidapi.com/nba")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = 'b75f06b51amshedbb7bbb363591fp1d8c49jsnea0e9ea45d3b'
    request["X-RapidAPI-Host"] = 'sports-data3.p.rapidapi.com'

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