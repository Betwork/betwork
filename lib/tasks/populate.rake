namespace :fill do
  desc 'Fill data'
  task data: :environment do
    require_relative '../populator_fixes.rb'
    require 'faker'
    require 'populator'
    puts 'Erasing existing data'
    puts '====================='

    [User, Post, Event, Comment, Odd, Bet].each(&:delete_all)
    ActsAsVotable::Vote.delete_all
    PublicActivity::Activity.delete_all

    puts 'Creating users'
    puts '=============='
    genders = ['male', 'female']
    password = 'betwork'

    User.populate 20 do |user|
      user.name = Faker::Name.name
      user.email = Faker::Internet.email
      user.sex = genders
      user.dob = Faker::Date.between(from: 45.years.ago, to: 15.years.ago)
      user.phone_number = Faker::PhoneNumber.cell_phone
      user.encrypted_password = User.new(password: password).encrypted_password
      user.confirmed_at = DateTime.now
      user.sign_in_count = 0
      user.posts_count = 0
      user.actualBalance = 999.99
      user.balanceInEscrow = 444.44
      puts "created user #{user.name}"
    end

    admin_user = User.new(name: 'Betwork', email: 'admin@betwork.com', sex: 'male', password: 'password')
    admin_user.actualBalance = 5000
    #admin_user.balanceInEscrow = 2222.24
    admin_user.skip_confirmation!
    admin_user.save!

    # Odd.populate 5 do |bet|
    #   bet.home_team_name = Faker::Name.name
    #   bet.away_team_name = Faker::Name.name
    #   bet.money_line= -110
    # end

    user = User.new(name: 'Rails', email: 'test@betwork.com', sex: 'male', password: 'password')
    user.actualBalance = 5000
    #user.balanceInEscrow = 2222.22
    user.skip_confirmation!
    user.save!
    puts 'Created test user with email=test@betwork.com and password=password'

    user = User.new(name: 'Rails-2', email: 'test2@betwork.com', sex: 'female', password: 'password')
    user.actualBalance = 4000
    #user.balanceInEscrow = 2222.22
    user.skip_confirmation!
    user.save!
    puts 'Created test user with email=test2@betwork.com and password=password'

    user = User.new(name: 'Andy M Birla', email: 'andymbirla@gmail.com', sex: 'male', password: 'password')
    user.actualBalance = 4000
    #user.balanceInEscrow = 2222.22
    user.skip_confirmation!
    user.save!
    puts 'Created test user with email=andymbirla@gmail.com and password=password'

    user = User.new(name: 'Andy Birla 96', email: 'andybirla96@gmail.com', sex: 'male', password: 'password')
    user.actualBalance = 4000
    #user.balanceInEscrow = 2222.22
    user.skip_confirmation!
    user.save!
    puts 'Created test user with email=andybirla96@gmail.com and password=password'

    user = User.new(name: 'Andy Birla 21', email: 'andy.birla21@gmail.com', sex: 'male', password: 'password')
    user.actualBalance = 4000
    #user.balanceInEscrow = 2222.22
    user.skip_confirmation!
    user.save!
    puts 'Created test user with email=andy.birla21@gmail.com and password=password'

    user = User.new(name: 'Andy Birla Columbia', email: 'ab5188@columbia.edu', sex: 'male', password: 'password')
    user.actualBalance = 4000
    #user.balanceInEscrow = 2222.22
    user.skip_confirmation!
    user.save!
    puts 'Created test user with email=ab5188@columbia.edu and password=password'

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

    # 15.times do
    #   event = Event.new
    #   event.name = Populator.words(1..3).titleize
    #   event.event_datetime = Faker::Date.between(from: 2.years.ago, to: 1.day.from_now)
    #   event.user = users.sample
    #   event.save
    #   puts "created event #{event.name}"
    # end

    puts 'Creating Likes For Posts'
    puts '========================'

    15.times do
      post = posts.sample
      user = users.sample
      post.liked_by user
      puts "post #{post.id} liked by user #{user.name}"
    end

    # puts 'Creating Likes For Events'
    # puts '========================='
    # events = Event.all

    # 15.times do
    #   event = events.sample
    #   user = users.sample
    #   event.liked_by user
    #   puts "event #{event.id} liked by user #{user.name}"
    # end

    # puts 'Creating Comments For Events'
    # puts '============================='

    # 15.times do
    #   event = events.sample
    #   user = users.sample
    #   comment = event.comments.new
    #   comment.commentable_type = 'Event'
    #   comment.comment = Populator.sentences(1)
    #   comment.user = user
    #   comment.save
    #   puts "user #{user.name} commented on event #{event.id}"
    # end

    puts 'Creating Odds for Bets'
    puts '============================='

  end
end
