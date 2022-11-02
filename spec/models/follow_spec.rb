require 'rails_helper'
# Follow rspec
RSpec.describe Follow, type: :model do
  subject {Follow.new(followable_type: "User", followable_id: 1, follower_type: "User", follower_id: 22, created_at: "2022-11-01 20:58:38.408190", updated_at: "2022-11-01 20:58:38.408190")}

  before { subject.save }

  it "followable_type should be present" do # followable_type blank
    subject.followable_type = nil
    expect(subject).to_not be_valid
  end

  it "followable_type should be present" do # followable_type valid
    subject.followable_type = "User"
    expect(subject).to be_valid
  end

  it "followable_id should not be invalid" do # invalid followable_id
    subject.followable_id = "ssss"
    expect(subject).to_not be_valid
  end

  it "followable_id should not be blank" do # blank followable_id
    subject.followable_id = nil
    expect(subject).to_not be_valid
  end

  it "followable_id is valid" do # valid followable_id
    subject.followable_id = 1
    expect(subject).to be_valid
  end

  it "follower_type should be present" do # follower_type blank
    subject.followable_type = nil
    expect(subject).to_not be_valid
  end

  it "follower_type should be present" do # follower_type valid
    subject.followable_type = "User"
    expect(subject).to be_valid
  end

  it "follower_id should not be invalid" do # invalid follower_id
    subject.follower_id = "ssss"
    expect(subject).to_not be_valid
  end

  it "follower_id should not be blank" do # blank follower_id
    subject.follower_id = nil
    expect(subject).to_not be_valid
  end

  it "follower_id is valid" do # valid follower_id
    subject.follower_id = 22
    expect(subject).to be_valid
  end

  it "created_at should not be invalid" do # invalid created_at
    subject.created_at = "ssss"
    expect(subject).to_not be_valid
  end

  it "created_at should not be blank" do # blank created_at
    subject.created_at = nil
    expect(subject).to_not be_valid
  end

  it "created_at is valid" do # valid created_at
    subject.created_at = "2022-11-01 20:58:38.408190"
    expect(subject).to be_valid
  end

  it "updated_at should not be invalid" do # invalid updated_at
    subject.updated_at = "ssss"
    expect(subject).to_not be_valid
  end

  it "updated_at should not be blank" do # blank updated_at
    subject.updated_at = nil
    expect(subject).to_not be_valid
  end

  it "updated_at is valid" do # valid updated_at
    created_at = DateTime.parse("2022-11-01 20:58:38.408190","%Y-%m-%d %H:%M:%S")
    subject.created_at = "2022-11-01 20:58:38.408190"

    updated_at = DateTime.parse("2022-11-01 21:58:38.408190","%Y-%m-%d %H:%M:%S")
    subject.updated_at = "2022-11-01 21:58:38.408190"

    expect(updated_at >= created_at)
    expect(subject).to be_valid

  end


end