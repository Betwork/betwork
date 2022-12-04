class GroupsMembershipsController < ApplicationController

  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def is_member
    @does_this_membership_exist = GroupMembership.find_by(user_id: params[:user_id], group_id: params[:group_id])
    return @does_this_membership_exist.nil?
  end

  def add_membership
    @memberships = GroupMembership.all
    puts "add membership triggered"
    # puts @memberships
    # puts @memberships[0].user_id, @memberships[0].group_id
    @does_this_membership_exist = GroupMembership.find_by(user_id: params[:user_id], group_id: params[:group_id])
    if @does_this_membership_exist.nil?
      flash[:notice] = "Successfully joined group"
      @group_membership = GroupMembership.new
      @group_membership.user_id = params[:user_id]
      @group_membership.group_id = params[:group_id]
      @group_membership.save
      redirect_to groups_path
      return
    end
    flash[:notice] = "Already a member"
    redirect_to groups_path
  end

  def remove_membership
    @memberships = GroupMembership.all
    puts "remove membership triggered"
    # puts @memberships
    # puts @memberships[0].user_id, @memberships[0].group_id
    @does_this_membership_exist = GroupMembership.find_by(user_id: params[:user_id], group_id: params[:group_id])
    if @does_this_membership_exist.nil?
      flash[:notice] = "Not a member"
      redirect_to groups_path
      return
    end
    flash[:notice] = "Successfully left group"
    puts @does_this_membership_exist
    puts @does_this_membership_exist.nil?
    @does_this_membership_exist.destroy
    redirect_to groups_path
  end

  # helper_method :add_or_remove_membership

  def update
    puts params
  end

  # def destroy
  # end

end
