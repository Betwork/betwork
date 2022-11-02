require 'rails_helper'
# User signup rspec
RSpec.describe Odd, type: :model do
  subject {User.new(name: 'Betty', email: 'Betty@betwork.com', password: 'password')}

  before { subject.save }

  it "name should be present" do # name blank
    subject.name = nil
    expect(subject).to_not be_valid
  end

  it "name should be present" do # name valid
    subject.name = "Matt"
    expect(subject).to be_valid
  end

  it "email should not be invalid" do # invalid email
    subject.email = "heyhihey"
    expect(subject).to_not be_valid
  end

  it "email should not be blank" do # blank email
    subject.email = nil
    expect(subject).to_not be_valid
  end

  it "email is valid" do # blank email
    subject.email = "test@gmail.com"
    expect(subject).to be_valid
  end

  it "password should not be incorrect length" do # 7 chars invalid
    subject.password = "aaaaaaa"
    expect(subject).to_not be_valid
  end

  it "password should be correct length" do # needs to be 8 chars
    subject.password = "aaaaaaaa"
    expect(subject).to be_valid
  end
end