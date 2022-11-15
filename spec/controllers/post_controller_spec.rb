require 'rails_helper'

RSpec.describe "Posts", type: :request do

  it "should be able to make a post" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    # @post = Post.create!("content": "hi", "user_id": @u1.id, "created_at": "2022-11-02 21:31:39.931748", "updated_at": "2022-11-02 21:31:39.931748", "content_html": "<p>hi</p>")

    @params = { :id => @u1.id, :post => { :content => 'hihihihi' } }
    # puts edit_post_path(@params)
    puts "made params"
    puts @params
    put post_path(@params)
    # puts "put the post"
    # # @new_post = Post.belongs_to(@u1)
    # # @post = Post.create!("content": "hi", "user_id": @u1.id, "created_at": "2022-11-02 21:31:39.931748", "updated_at": "2022-11-02 21:31:39.931748", "content_html": "<p>hi</p>")
    # # expect(@new_post).to be_valid
    # allposts = Post.all
    # puts allposts.length()it s
    # puts "PLEASSE GOD"
  end

end


