class BetsController < ApplicationController
    before_action :set_user

    def placebet
      @friend = User.find_by(id: params[:friend_id])
      @game = Odd.find params[:game]
    end

    def allbets
      @user_bets = Bet.get_by_userid(current_user.id)
    end

    def new 
      @bet = Bet.new
    end

    def updatebet
    end

    def confirm 
    end

    def edit 
    end 

    def create
      @bet = Bet.new(bet_params)
      @bet.save
      redirect_to confirm_bet_path("1")
    end

    def update
      @bet.update(user_params)
    end

    # def index
    #     @odds = Odd.all
    # end
    #
    # def friends
    #     puts params[:page]
    #     @friends = @user.following_users.paginate(page: params[:page])
    #     @game = Odd.find params[:id]
    # end
    #
    # def show
    #     @odds = Odd.all
    # end

private

def user_params
  params.require(:user).permit(:name, :about, :avatar, :cover,
                               :sex, :dob, :location, :phone_number)
end

def bet_params
  params.require(:bet).permit(:team_one_name, :team_two_name, :money_line, :user_one_name, :user_two_name, :amount, :user_id_one, :user_id_two)
end

def check_ownership
  redirect_to current_user, notice: 'Not Authorized' unless @user == current_user
end

def set_user
  @user = current_user 
  render_404 and return unless @user
end
end