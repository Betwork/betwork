## BETWORK 
Betwork is a sports betting application built for sports enthusiasts who are tired of losing money to the house. Betwork allows you to ditch the bookie and makes sports betting enjoyable once again!

### Setup 

Clone this repo using the following command:

```
git clone https://github.com/Betwork/betwork.git 
cd betwork 
```
Then use bundler to install all dependencies 

```
bundle install
bundle update
```

Run Migrations and populate with Mock Data:

```
rake db:drop
rake db:migrate
rake fill:data
rake db:seed
```

Run rails using

```
rails server
```

### Testing

Login with Test User credentials or create your own via sign-up:

* email: test@betwork.com
* password: password

Current capabilities to test:
* Login with given credentials or sign-up on your own
* Navigate to Find Friends, follow (add) new friends, navigate to My Friends to view your current friends
* Once you have a friend, navigating to Live Bets shows you the current games that can be bet on
* Choose a game to bet on (Place Bet) and choose a friend to bet against (Place Bet)
* Enter an amount to bet, and confirm your bet 
* Navigate back to the home page and go to My Bets to see a list of your current bets
* Sign out

Run cucumber tests using
```
rails g cucumber:install
If asked to overwrite, enter n for NO
rake db:migrate RAILS_ENV=test
bundle exec cucumber
```
Run RSPEC tests using
```
```