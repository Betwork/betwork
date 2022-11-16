require_relative '../../lib/populator_fixes.rb'
require 'faker'
require 'populator'


When /I hit return/ do
  find(:id, 'user_password').native.send_keys(:enter)
end

Given /the user database has been cleared/ do 
  [User].each(&:delete_all)
  # sleep(3)
end

Given /the Betwork test database exists/ do 
  puts 'Erasing existing data'
  puts '====================='

  [User, Post, Event, Comment, Odd].each(&:delete_all)
  ActsAsVotable::Vote.delete_all
  PublicActivity::Activity.delete_all

  puts 'Creating users'
  puts '=============='
  genders = ['male', 'female']
  password = 'betwork'

  User.populate 5 do |user|
    user.name = Faker::Name.name
    user.email = Faker::Internet.email
    user.sex = genders
    user.dob = Faker::Date.between(from: 45.years.ago, to: 15.years.ago)
    user.phone_number = Faker::PhoneNumber.cell_phone
    user.encrypted_password = User.new(password: password).encrypted_password
    user.confirmed_at = DateTime.now
    user.sign_in_count = 0
    user.posts_count = 0
    puts "created user #{user.name}"
  end

  Odd.populate 1 do |bet|
    bet.home_team_name = "Los Angeles Lakers"
    bet.away_team_name = "New York Knicks"
    bet.home_money_line= -110
    bet.away_money_line= -110
    bet.date="6:00 ET 11/20/2022"
  end

  Odd.populate 5 do |bet|
    bet.home_team_name = Faker::Name.name
    bet.away_team_name = Faker::Name.name
    bet.home_money_line= -110
    bet.away_money_line= -110
    bet.date="6:00 ET 11/20/2022"
  end

  user = User.new(name: 'Rails', email: 'test@betwork.com', sex: 'male', password: 'password', actualBalance: "0", balanceInEscrow: "0")
  user.skip_confirmation!
  user.save!
  puts 'Created test user with email=test@betwork.com and password=password'

  puts 'Generate Friendly id slug for users'
  puts '==================================='
  User.find_each(&:save)

  puts 'Creating Posts'
  puts '=============='
  users = User.all

  15.times do
    post = Post.new
    post.content = Populator.sentences(2..4)
    post.user = users.sample
    post.save!
    puts "created post #{post.id}"
  end

  puts 'Creating Comments For Posts'
  puts '==========================='

  posts = Post.all

  15.times do
    post = posts.sample
    user = users.sample
    comment = post.comments.new
    comment.comment = Populator.sentences(1)
    comment.user = user
    comment.save
    puts "user #{user.name} commented on post #{post.id}"
  end

  puts 'Creating Events'
  puts '==============='

  15.times do
    event = Event.new
    event.name = Populator.words(1..3).titleize
    event.event_datetime = Faker::Date.between(from: 2.years.ago, to: 1.day.from_now)
    event.user = users.sample
    event.save
    puts "created event #{event.name}"
  end

  puts 'Creating Likes For Posts'
  puts '========================'

  15.times do
    post = posts.sample
    user = users.sample
    post.liked_by user
    puts "post #{post.id} liked by user #{user.name}"
  end

  puts 'Creating Likes For Events'
  puts '========================='
  events = Event.all

  15.times do
    event = events.sample
    user = users.sample
    event.liked_by user
    puts "event #{event.id} liked by user #{user.name}"
  end

  puts 'Creating Comments For Events'
  puts '============================='

  15.times do
    event = events.sample
    user = users.sample
    comment = event.comments.new
    comment.commentable_type = 'Event'
    comment.comment = Populator.sentences(1)
    comment.user = user
    comment.save
    puts "user #{user.name} commented on event #{event.id}"
  end
end

And /I take a screenshot/ do
  page.save_screenshot('test.png')
end

Given /the admin user has money/ do
    User.where(name: "Rails").update_all(actualBalance: 500)
end

Then /I navigate to the dropdown-menu/ do
  find(:xpath, '//*[@id="navbar-top"]/ul').click
end

Then /I sign out of Betwork/ do 
  find(:xpath, '/html/body/nav/div/div[2]/ul/li/ul/li[4]/a').click
end

When /I last press follow/ do
  within all(".follow").last do
    click_button("follow")
  end
end

When /I place a bet on the first game/ do
  visit '/odds/1/friends'
end

When /I first press place bet/ do
  visit '/bets/1/placebet?amount=-1&friend_id=7&game=1'
end

Given /my test friend exists/ do
  user = User.new(name: 'Betty', email: 'Betty@betwork.com', sex: 'female', password: 'password', actualBalance: 500, balanceInEscrow: 0)
  user.skip_confirmation!
  user.save!
end

When /^(?:|I )balance form select "([^"]*)"$/ do |option|
  select option, :from => "balance_change_type"
end

Given /I have placed a bet/ do # STUCK
  bet = Bet.create!(home_team_name: "LAL", away_team_name: "CHI", betting_on: "Home Team", home_money_line: "-220", away_money_line: "+150", user_one_name: "Rails", user_two_name: "Betty", amount: "50", user_id_one: 6, user_id_two: 7, date: "2022-11-15", status: "proposed")
  bet.save!
  User.where(name: "Rails").update_all(balanceInEscrow: 50)
end

Then /I sleep/ do
  sleep(60)
end