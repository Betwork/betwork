require 'rails_helper'

RSpec.describe "Comments", type: :request do
  it "should be able to make a comment" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: 100, balanceInEscrow: 0)
    @u1.skip_confirmation!
    @u1.save!
    sign_in @u1
    @p1 = Post.create!(content: "abcdefg", created_at: DateTime.now, updated_at: DateTime.now, user_id: @u1.id)
    puts @p1.id
    @params = { :commentable_id => @p1.id, :commentable_type => "Post" }
    # post comments_path(@params)
    # allComments = Comment.all
    # @params = { :likeable_id => @p1.id, :likeable_type => "Post" }
    # post like_path(@params)
    # @params = { :likeable_id => @p1.id, :likeable_type => "Post" }
    # post unlike_path(@params)
  end

end


