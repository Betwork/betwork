require 'rails_helper'
# require 'spec_helper'
RSpec.describe "Posts", type: :request do
  it "should be able to create a post" do
    @user = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @user.skip_confirmation!
    @user.save!
    sign_in @user
    # @params = { :id => @user, :post => { :content => 'hi' } }
    @params = { :id => 100, :post => { :content => 'hi' } }
    # @params = { :id => 100, :post => { :content => 'hi', :user_id => @user.id, :content_html => "<p>hi/p>" } }
    post posts_path(@params)
    allPosts = Post.all
    puts allPosts.length()
    expect(allPosts[0].content).to eq('hi')
  end

  it "should be able to edit a post" do
    @user = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @user.skip_confirmation!
    @user.save!
    sign_in @user

    @post = Post.create!("content": "hi", "user_id": @user.id, "created_at": "2022-11-02 21:31:39.931748", "updated_at": "2022-11-02 21:31:39.931748", "content_html": "<p>hi</p>")
    allPosts = Post.all
    expect(allPosts[0].content).to eq('hi')
    @params = { :id => @post.id, :post => { :content => 'CHANGED POST CONTENT' } }
    put post_path(@params)
    allPosts = Post.all # refresh allPosts
    expect(allPosts[0].content).to eq('CHANGED POST CONTENT')
  end

  it "should be able to delete a post" do
    @user = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @user.skip_confirmation!
    @user.save!
    sign_in @user
    # # @params = { :id => @user, :post => { :content => 'hi' } }
    # @params = { :id => 100, :post => { :content => 'hi' } }
    # # @params = { :id => 100, :post => { :content => 'hi', :user_id => @user.id, :content_html => "<p>hi/p>" } }
    # post posts_path(@params)
    @post = Post.create!("content": "hi", "user_id": @user.id, "created_at": "2022-11-02 21:31:39.931748", "updated_at": "2022-11-02 21:31:39.931748", "content_html": "<p>hi</p>")
    allPosts = Post.all
    expect(allPosts[0].content).to eq('hi')
    @params = { :id => @post.id }
    delete post_path(@params)
    allPosts = Post.all
    expect(allPosts.length()).to eq(0)
  end

end


