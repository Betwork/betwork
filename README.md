## BETWORK 
Betwork is a sports betting application built for sports enthusiasts who are tired of losing money to the house. Betwork allows you to ditch the bookie and makes sports betting enjoyable once again!

Team:
* Jordi Adoumie - jja2163
* Solomon Chang - sjc2233
* Matthew Golden - mtg2158
* Anirudh Birla - ab5188

### Links
1) Link to Betwork's Github Repo:
```
https://github.com/Betwork/betwork.git
```
2) Link to Heroku Deployment of Betwork:
```
https://arcane-tundra-65485.herokuapp.com/
```

### Setup 

1) Clone and enter this repo using the following command:

```
git clone https://github.com/Betwork/betwork.git 
cd betwork
git checkout master
git pull
```
2) Navigate to the `proj-iter1` branch to view the code at submission time:

```
git fetch
git branch -r
git checkout --track origin/proj-iter1
git pull
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

Run cucumber tests for users (signing in/up/out), friends, and betting using
```
rails g cucumber:install
If asked to overwrite, enter n for NO
rake db:migrate RAILS_ENV=test
bundle exec cucumber
```
Run RSPEC tests for users (parameter validation), friends, odds, betting, and posting using
```
rake spec
```
It must be noted that the features/functionality that we have tested apply solely to those that we deem relevant to our application from the template used. For this reason, a pure coverage report of `cucumber` or `rspec` tests will not pain an accurate picture as to the required  