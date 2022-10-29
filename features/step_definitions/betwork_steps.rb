Given /the admin user exists/ do 
    user = User.new(name: 'Rails', email: 'test@betwork.com', sex: 'male', password: 'password')
    user.skip_confirmation!
    user.save!
      # each returned element will be a hash whose key is the table header.
      # you should arrange to add that movie to the database here.
    #pending "Fill in this step in movie_steps.rb"
end