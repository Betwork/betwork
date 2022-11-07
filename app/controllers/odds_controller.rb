class OddsController < ApplicationController
    before_action :set_user

    def index
        #@odds = Odd.all
        Odd.delete_all
        odds = find_nba_odds()
        odds.each do |odd|
          new_odd = Odd.new
          new_odd.home_team_name = odd['homeTeam']
          new_odd.away_team_name = odd['awayTeam']
          new_odd.home_money_line = odd['homeMoneyLine']
          new_odd.away_money_line = odd['awayMoneyLine']
          new_odd.date = odd['startTime']
          new_odd.save
        end
        @odds = Odd.all
    end

    def friends
        puts params[:page]
        @friends = @user.following_users.paginate(page: params[:page])
        @game = Odd.find params[:id]
        @amount = params[:amount].nil? ? -1 : params[:amount]
    end

    def show
        @odds = Odd.all
    end

private

def request_api(url)
  response = Excon.get(
    url,
    headers: {
      'X-RapidAPI-Host' => URI.parse(url).host,
      #'X-RapidAPI-Key' => "0922e8a07dmsh4cacadace93e259p191ebajsn446e95a439bc" 
      'X-RapidAPI-Key' => ENV.fetch('RAPIDAPI_API_KEY')
    }
  )

  return nil if response.status != 200

  puts JSON.parse(response.body)
  JSON.parse(response.body)
end

def find_nba_odds()
  request_api('https://sports-data3.p.rapidapi.com/nba')
end




def user_params
  params.require(:user).permit(:name, :about, :avatar, :cover,
                               :sex, :dob, :location, :phone_number)
end

def check_ownership
  redirect_to current_user, notice: 'Not Authorized' unless @user == current_user
end

def set_user
  @user = current_user 
  render_404 and return unless @user
end
end