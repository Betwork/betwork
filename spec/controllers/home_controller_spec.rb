require 'rails_helper'

RSpec.describe "Home", type: :request do
  it "should be able to access the home page" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: 100, balanceInEscrow: 0)
    @u1.skip_confirmation!
    @u1.save!
    sign_in @u1
    get about_path
    get find_friends_path
  end
end



