require 'rails_helper'

RSpec.describe "Users", type: :request do
  it "should be able to see a users balance" do
    @u1 = User.create!(name: 'Betty', email: 'Betty@betwork.com', password: 'password', actualBalance: 100, balanceInEscrow: 0)
    @u1.skip_confirmation!
    @u1.save!
    sign_in @u1

    @params = { :id => @u1.name, :balance_change => 0, :balance_change_type => "Add",
                :user => { :actualBalance => @u1.actualBalance } }
    # @params = { :id => @u1.name }
    patch user_path(@params)
    allUsers = User.all #refresh allUsers
    expect(allUsers[0].actualBalance).to eq(100)
  end

end


