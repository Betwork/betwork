class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :check_ownership, only: [:edit, :update]
  respond_to :html, :js

  def show
    @activities = PublicActivity::Activity.where(owner: @user).order(created_at: :desc).paginate(page: params[:page], per_page: 10)
  end

  def edit
  end

  def is_number? string
    true if Float(string) rescue false
  end

  def update
    # puts "we in  the fucking update"
    # puts params
    if !is_number?(params[:balance_change]) or params[:balance_change].to_f < 0
      redirect_to user_path(@user), notice: "Invalid input, please input a number greater than zero"
      return
    end
    if params[:balance_change_type] == "Add"
      params[:user][:actualBalance] = @user.actualBalance + params[:balance_change].to_f
    else
      if params[:balance_change].to_f > (@user.actualBalance - @user.balanceInEscrow)
        redirect_to user_path(@user), notice: "Cannot withdraw more than your Actual Balance minus Pending Bets"
        return
      end
      params[:user][:actualBalance] = @user.actualBalance - params[:balance_change].to_f
    end
    if @user.update(user_params)
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  def deactivate
  end

  def friends
    @friends = @user.following_users.paginate(page: params[:page])
  end

  def followers
    @followers = @user.user_followers.paginate(page: params[:page])
  end

  def mentionable
    # puts "in mentionable"
    # puts params
    # puts params[:page]
    render json: @user.following_users.as_json(only: [:id, :name]), root: false
  end

  private

  def user_params
    params.require(:user).permit(:name, :about, :avatar, :cover,
                                 :sex, :dob, :location, :phone_number, :actualBalance)
  end

  def check_ownership
    # puts "checking ownership"
    # puts params
    # puts @user
    # puts @user.name
    # puts current_user
    # # puts current_user.name
    # puts "what's printed"
    redirect_to current_user, notice: 'Not Authorized' unless @user == current_user
  end

  def set_user
    # puts "USER PARAMS WEEEEEEEE"
    # puts params
    @user = User.friendly.find_by(slug: params[:id]) || User.find_by(id: params[:id])
    # puts @user.id
    # puts @user.name
    render_404 and return unless @user
  end
end
