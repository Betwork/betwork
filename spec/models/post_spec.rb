require 'rails_helper'


RSpec.describe Post, type: :model do

  it "should be able to make a bet" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @post = Post.create!("content": "hi", "user_id": @u1.id, "created_at": "2022-11-02 21:31:39.931748", "updated_at": "2022-11-02 21:31:39.931748", "content_html": "<p>hi</p>")
    expect(@post).to be_valid
  end




end


