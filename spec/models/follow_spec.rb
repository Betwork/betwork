require 'rails_helper'


RSpec.describe Follow, type: :model do


  it "should be able to follow another user" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1')
    @follow = Follow.create!("followable_type": "User", "followable_id": @u1.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")
    expect(@follow).to be_valid
    expect(@follow.followable_id == @u1.id)
  end

  it "should be able to follow another user, unfollow that user and follow them again" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1')
    @follow = Follow.create!("followable_type": "User", "followable_id": @u1.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")
    @follow.destroy
    @follow1 = Follow.create!("followable_type": "User", "followable_id": @u1.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")
    expect(@follow1).to be_valid
    expect(@follow1.followable_id == @u1.id)
  end

  it "should be able to see users you followed" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1')
    @u3 = User.create!(name: 'Betty2', email: 'Betty2@betwork.com', password: 'password2')
    @follow = Follow.create!("followable_type": "User", "followable_id": @u1.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")
    @follow1 = Follow.create!("followable_type": "User", "followable_id": @u3.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")
    @follows = Follow.where(follower_id: @u2.id)
    for follow in @follows
      expect([@u1.id, @u3.id].include? follow.followable_id)
    end
  end

  it "should be able to block a followed user" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1')
    @follow = Follow.create!("followable_type": "User", "followable_id": @u1.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")
    @follow.block!()
    expect(@follow).to be_valid
    expect(@follow.blocked == true)
  end

  it "should be able to see users you followed that you did not block" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1')
    @u3 = User.create!(name: 'Betty2', email: 'Betty2@betwork.com', password: 'password2')
    @follow = Follow.create!("followable_type": "User", "followable_id": @u1.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")
    @follow1 = Follow.create!("followable_type": "User", "followable_id": @u3.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")
    @follow.block!()
    @follows = Follow.where(follower_id: @u2.id, blocked: nil)
    for follow in @follows
      expect([@u3.id].include? follow.followable_id)
    end
  end

  it "should be able to see users that you have not followed or blocked" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password')
    @u2 = User.create!(name: 'Betty1', email: 'Betty1@betwork.com', password: 'password1')
    @u3 = User.create!(name: 'Betty2', email: 'Betty2@betwork.com', password: 'password2')
    @u4 = User.create!(name: 'Betty3', email: 'Betty3@betwork.com', password: 'password3')
    @follow = Follow.create!("followable_type": "User", "followable_id": @u1.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")
    @follow1 = Follow.create!("followable_type": "User", "followable_id": @u3.id, "follower_type": "User", "follower_id": @u2.id, "created_at": "2022-11-01 20:58:38.408190", "updated_at": "2022-11-01 20:58:38.408190")
    @follow.block!()
    @follows = Follow.where(follower_id: @u2.id)
    for follow in @follows
      expect(!([@u4.id].include? follow.followable_id))
    end
  end




end