class OddsController < ApplicationController
    before_action :set_user

    def index
        @odds = Odd.all
    end

    def friends
        @friends = @user.following_users.paginate(page: params[:page])
        @game = Odd.find params[:id]
    end

    def show
        @odds = Odd.all
    end

private

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