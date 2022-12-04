class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  # GET /groups
  def index
    @groups = Group.all
  end

  # GET /groups/1
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  def create
    puts "ok"
    puts group_params
    puts params
    puts params[:type]
    puts params[:name]
    puts params[:group][:creator_id]
    puts "ok"

    @group = Group.new(group_params)
    @group.name_of_group = params[:group][:name_of_group]
    @group.creator_id = params[:group][:creator_id]

    if @group.save
      puts @group.id
      redirect_to @group, notice: 'Group was successfully created.'
    else
      render :new
    end
  end

  # def add_or_remove(group_id, user_id)
  #   # redirect_to add_or_remove_membership_path(group_id, user_id)
  #   puts "groups add or remove triggered"
  #   @membership_contr = GroupsMembershipsController.new
  #   @membership_contr.add_or_remove_membership(group_id, user_id)
  # end
  #
  # helper_method :add_or_remove

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      redirect_to @group, notice: 'Group was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
    redirect_to groups_url, notice: 'Group was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def group_params
    params.permit(:type)
    # params.require(:group).permit(:name)
  end
end
