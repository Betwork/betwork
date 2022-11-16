class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def show
    # puts "TRIEGGER show"
    @comments = @post.comments.all
  end

  def create
    # puts "TRIEGGER create"
    # puts params
    # puts post_params
    # puts "TEST THIS OUT NOW PLEASE"
    @post = current_user.posts.new(post_params)
    if @post.save
      redirect_to root_path
    else
      redirect_to root_path, notice: @post.errors.full_messages.first
    end
  end

  def edit
    # puts "TRIEGGER edit"
    # puts post_params
  end

  def update
    # puts "TRIEGGER update"
    # puts post_params
    # puts "before update content"
    # puts @post.content
    @post.update(post_params)
    # puts "after update content"
    # puts @post.content
    redirect_to @post
  end

  def destroy
    # puts "TRIEGGER destroy"
    # puts Post.all.length()
    @post.destroy
    # puts Post.all.length()
    respond_to do |format|
      format.js
      format.html { redirect_to root_path }
    end
  end

  private

  def set_post
    # puts "TRIEGGER set_post"
    @post = Post.find_by(id: params[:id])
    # puts @post
    render_404 and return unless @post && User.find_by(id: @post.user_id)
  end

  def post_params
    # puts "TRIEGGER post_params"
    params.require(:post).permit(:content, :attachment)
  end
end
