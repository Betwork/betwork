require 'rails_helper'

RSpec.describe "Posts", type: :request do
  # it "should be able to create a post" do
  #   @u2 = User.create!(name: 'Betty2', email: 'Betty2@betwork.com', password: 'password')
  #   # @params = { :id => @u2, :post => { :content => 'hi' } }
  #   @params = { :id => @u2.id, :post => { :content => 'hi' } }
  #   # post :create, params: @params
  #   put post_path(@params)
  #   allPosts = Post.all
  #   puts allPosts.length()
  #   expect(allPosts[0].content == 'hi')
  # end

  it "should be able to edit a post" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @post = Post.create!("content": "hi", "user_id": @u1.id, "created_at": "2022-11-02 21:31:39.931748", "updated_at": "2022-11-02 21:31:39.931748", "content_html": "<p>hi</p>")
    @params = { :id => @post.id, :post => { :content => 'CHANGED POST CONTENT' } }
    put post_path(@params)
    allPosts = Post.all
    expect(allPosts[0].content == 'CHANGED POST CONTENT')
  end

  # it "should be able to delete a post" do
  #   @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
  #   @post = Post.create!("content": "hi", "user_id": @u1.id, "created_at": "2022-11-02 21:31:39.931748", "updated_at": "2022-11-02 21:31:39.931748", "content_html": "<p>hi</p>")
  #
  #   # delete :destroy
  #   # delete :destroy, params: { id: @post.id }
  #   @params = { current_user => @u1, :id => @post.id, :method => :delete }
  #   get post_path(@params)
  #   # allPosts = Post.all
  #   # puts allPosts.length()
  # end

end


