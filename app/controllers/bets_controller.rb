require 'test.rb'
require_relative "../constants/bet_post_constants.rb"

class BetsController < ApplicationController
    before_action :set_user
    respond_to :html, :js

    def placebet
      @friend= User.find_by(id: params[:friend_id])
      @@friend_user = @friend
      @game = Odd.find params[:game]
      @bet = Bet.new
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
      # @bet = Bet.find params[:id]
      # admin_user = User.get_admin_user()
      # @friend= User.find_by(id: params[:friend_id])
      # @@friend_user = @friend
      # content_string = create_bet_message_string(current_user, @@friend_user, @bet)
      # test = {"content"=> content_string}
      # @post = admin_user.posts.new(test)
      # @post.save
    end

    def receive
      @bet = Bet.find params[:id]
      @amount = @bet.amount
      if (current_user.actualBalance - current_user.balanceInEscrow) - @amount < 0.0
        redirect_to allbets_bet_path(current_user), notice: "Insufficient Funds"
        return
      else
        current_user.increase_balance_in_escrow(@amount)
      end
      @bet.status = 'confirmed'
      @bet.save
      admin_user = User.get_admin_user()
      @friend= User.find_by(id: @bet.user_id_two)
      @@friend_user = @friend
      @original = User.find_by(id: @bet.user_id_one)
      @@original_user = @original
      content_string = create_bet_message_string(@@original_user, @@friend_user, @bet)
      test = {"content"=> content_string}
      @post = admin_user.posts.new(test)
      @post.save
      redirect_to allbets_bet_path(current_user), notice: "Bet Accepted!"
    end

    def cancel
      @bet = Bet.find params[:id]
      @amount = @bet.amount
      @status = @bet.status
      @friend= User.find_by(id: @bet.user_id_two)
      if (current_user.name == @bet.user_two_name)
        @friend= User.find_by(id: @bet.user_id_one)
      end
      if (@status == 'confirmed')
        current_user.increase_balance_in_escrow(-@amount)
        @friend.increase_balance_in_escrow(-@amount)
        admin_user = User.get_admin_user()
        @@friend_user = @friend
        content_string = create_bet_cancel_message_string(current_user, @@friend_user, @bet)
        test = {"content"=> content_string}
        @post = admin_user.posts.new(test)
        @post.save
      elsif ((@status == 'proposed') && (current_user.name == @bet.user_one_name))
        current_user.increase_balance_in_escrow(-@amount)
      elsif ((@status == 'proposed') && (current_user.name == @bet.user_two_name))
        @friend.increase_balance_in_escrow(-@amount)
      end
      @bet.status = 'cancelled'
      @bet.save
      redirect_to allbets_bet_path(current_user), notice: "Bet Cancelled!"
    end

    def edit 
    end 

    def create
      @bet = Bet.new(bet_params)
      if @bet.save
       current_user.increase_balance_in_escrow(@bet.amount)
       render js: "window.location='#{confirm_bet_path(@bet)}'"
      else 
        respond_to do |format|
        format.js
        @bet.errors.any?
        @bet.errors.each do |key, value|
        end
      end 
      end 
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
  params.require(:bet).permit(:home_team_name, :away_team_name, :home_money_line, :date,
    :away_money_line, :user_one_name, :betting_on, :user_two_name, :amount, :user_id_one, :user_id_two, :status)
end

def check_ownership
  redirect_to current_user, notice: 'Not Authorized' unless @user == current_user
end

def set_user
  @user = current_user 
  render_404 and return unless @user
end
end