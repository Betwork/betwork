


# Betwork
*Ditch the Bookie!*

Betwork is a sports betting application built by Columbia students as a final project for the course COMS 4152: Engineering Software as a Service in the Fall of 2022. The application primarily targets sports enthusiasts who are tired of losing money to the house and would rather be able to bet directly against their fellow sports enthusiasts.


## Table of Contents
1. [Team](#team)
2. [Quick Links](#quick-links)
3. [Introduction](#introduction)
4. [Features](#features)
5. [Codebase](#codebase)
6. [Workflow](#workflow)
7. [Local Deployment](#local-deployment)
8. [Heroku Deployment](#heroku-deployment)
9. [Testing](#testing)
10. [Future Development](#future-development)


## Team
Our team consists of the following four students currently enrolled in Columbia University's MS in Computer Science Program:
* Jordi Adoumie - jja2163@columbia.edu
* Solomon Chang - sjc2233@columbia.edu
* Matthew Golden - mtg2158@columbia.edu
* Anirudh Birla - ab5188@columbia.edu


## Quick Links
To quickly access any of the critical deliverables of the project, use the links below:
1) Betwork's Github Repo: https://github.com/Betwork/betwork.git
2) Heroku Deployment of Betwork: http://fierce-hollows-46387.herokuapp.com/


## Introduction
As mentioned above, Betwork is a social gambling platform centered around sports with the following main features:
1) Similar to other social networking platforms, Betwork allows users to add friends and make groups of friends.
2) Betwork's Unique Selling Point (USP) is that it then allows users to place bets directly with their friends or with groups of friends based on the outcome of various sports or the performance of various athletes. In this way, Betwork completely ditches the concept of the bookie and creates a socially engaging atmosphere for people to network with other sports enthusiasts while also placing bets against one another to foster a competitive spirit.
3) Users can choose the outcomes they want to bet on, who they bet against and the odds they bet at allowing them a more personalized betting experience.

For more information on the research and thought process that went into conceptualizing Betwork, please find the original project proposal using the following Google Drive link (accessible to anyone with LionMail): https://drive.google.com/file/d/1G8MNKlY7QVG0UcnslH44GTRCueBDX9kg/view?usp=sharing


## Features
As the team proceeds with building out Betwork, it is concerned with which new Feature flows to target to benefit users of the application as well addressing any technical debt, pending issues or suggested improvements from the previous iteration of the project.


### Major Flows
In its current state (Project-Launch), the application can be tested using the Test User credentials (or create your own via sign-up locally or on Heroku):
* email: test@betwork.com
* password: password

Following are the major feature flows that the application supports with:
* Login with given credentials or sign-up on your own
* Navigate to Find Friends to follow (add) new friends
* Navigate to My Friends to view your current friends
* Next, navigate to Manage Funds to deposit or withdraw money
* Once you have money and friends, navigating to Live Bets shows you real-time the current games that can be bet on (RapidAPI Live)
* Games across the NBA, NFL, and NHL are supported
* Choose a game to bet on (Place Bet) and choose a friend to propose a bet against (Place Bet)
* Enter an amount to bet, and confirm your bet
* Navigate back to the home page where you will see your updated balance (with pending bets) and now go to My Bets
* Flows exist for automatically sending texts and emails to users based on their bet progression
* On this page, you can see your confirmed, proposed, received, finished, and cancelled bets
* Should you decide to cancel your proposed bet, you may do so by clicking Cancel Bet prior to the opponent accepting the bet
* Should you decide to decline an incoming bet, you may also do so by clicking Cancel Bet
* After winning (or losing) a bet, your balance will update in My Funds where you can withdraw your winnings (winnings will automatically be paid out after a game has been completed)
* Sign out

In order to test what it is like being on the receiving end of some of the above, you can use the Test User 2 credentials (or create your own via sign-up locally):
* email: test2@betwork.com
* password: password

### Example Screenshots
![Image1](https://i.imgur.com/oQWqdMO.png?raw=true "Title")
Betwork home page that shows recent betting activity and your current balance.
* Actual Balance is total funds to your name
* Pending bets are the amount of money in escrow for pending bets
* Available Balance is total funds you can actually bet with

![Image2](https://i.imgur.com/wAJRxnX.png?raw=true "Title")
Betwork Live Odds page that shows today's NBA game matchups with odds and time.

![Image3](https://i.imgur.com/Cuj5T62.png?raw=true "Title")
Betwork My Bets page that shows your confirmed, proposed, received, finished, and cancelled bets with action buttons to cancel outgoing/incoming bet proposals.

![Image4](https://i.imgur.com/gdM6roM.png?raw=true "Title") 
Betwork My Funds page that allows the user to see their balance and manage funds by depositing/withdrawing money.

### Improvements from Iteration 2
Following are the improvements made by the team on Betwork from Iteration 2 to Project Launch:
1) Twilio was set up so we could create automated texting features! We were able to demo out this feature during our proj-demo and it is incorporated in the code - however, texts will only be sent to Jordi Adoumie's phone # at this point in time because of Twilio Rules and the associated cost to deploy to all numbers generally.
2) AWS SES allows for emailing users the status of their games! Similar to the Twilio texting features, this will only send emails to email addresses that are already verified. Because of free-tier, we are not able to email all users who sign up. They must first be verified through AWS SES. 
3) AWS Lambda functions + Dynamo DB! We deployed logic into the cloud to check the status of all bets in the database every 2 hours and appropriately move bets out of "confirmed" status to "finished" status based on who won and who lost! Your user will get automatically paid out!
4) Added NFL + NHL Odds! So now you can bet across three differrent proffesional leagues --> NBA, NFL, NHL
5) API Refactoring: We decided the APIs we had used to date were not stable enough and did not support a wide variety of sports. To remedy this, we had to refactor A LOT of the code to be set up with the newer API we are using. 
6) Sign Up Refactoring: Any user can now sign up for the platform! Follow the sign-up workflow and you will receive an email to the email provided during sign-up. After verifying your email address you will be able to log-in!
7) Users cannot cancel or propose a bet if it is within 2 hours of the game commencing. This was a feature we decided to implement to better support real-life betting scenarios. Oftentimes, after a bet is confirmed, the Bookie will not let users cancel bets. However, since Betwork is NOT A BOOKIE... we allow users to cancel their bet as long as it is before 2 hours of game time! You also cannot propose a bet to another user if it is within 2 hours of a game starting. 
8) Users can bet on games that are upcoming within a few days (previously could only bet on games that were occuring on the same day). Some sports like NFL require this type of betting availability. 

## Codebase
As mentioned above, the application was written as a final project for the course COMS 4152: Engineering Software as a Service in the Fall of 2022. Following are the notable features of the codebase:
1) The Betwork framework was built on top of an existing template for a rudimentary social media application, Socify. The Medium article explaining its construction can be found at: https://medium.com/rails-ember-beyond/how-to-build-a-social-network-using-rails-eb31da569233.
2) The original source code from the aforementioned article can be found at: https://github.com/scaffeinate/socify/tree/stable.
3) The original framework was implemented in Ruby on Rails and Betwork team expanded on this. The application thus runs on `Ruby 2.6.6` and `Rails 5.2.0`.
4) Various application logic is also hosted on AWS through lambda functions + DynamoDB to help facilitate automated email, texting, and database cleanup when games are completed (settlement process of bets)

## Workflow
The team used Github to manage both the flow of work as well as the codebase itself in the following way:
1) The original repository was cloned into a new repository within the Betwork organization.
2) The team then ensured that the original Socify application could be started up and run stably across the local machines of all the team members. This involved fixing the Gemfile, ActiveRecord Migration versions, etc. Once these fixes were in place, all the changes were merged into the `master` branch of the Betwork Github repo.
3) The team proceeded to outline various features (such as friending, betting, making a post, etc.) to be focussed on for each iteration of the project. Each feature was represented by its own Milestone on Github.
4) Each Milestone was further subdivided into the necessary tasks to be completed for the feature to be functioning to the level expected for that iteration. These tasks were represented as Issues on Github.
5) Each Issue was assigned to a team member who created a new remote branch for the same that was automatically linked to the issue. Once the team member had committed and pushed all the necessary code for the Issue to the remote branch, they opened a PR for the same.
6) The PR was reviewed by at least one other member (preferably a member working on a similar feature). If both the written code and the feature itself passed the inspection, the branch was merged into `master`.
7) Merging the branch into `master` and closing the PR automatically closed the linked Issue and updated the completion percentage of the corresponding Milestone. Thus at any given point of time, the team could easily establish:
    1) the features completed by different team members
    2) the features currently being worked on by different team members
    3) the roadmap ahead until the next iteration of the project was due.
8) The team followed a pair programmer concept where the reviewer of the PR took up the responsibility of writing the tests (both Cucumber and Rspec) for the same. This not only eased distribution of work but also ensured that at any given point of time, at least two team members had an in-depth understanding of the code surrounding each feature.

## Local Deployment
In order to simplify the local setup of the application for a user wishing to test the application on their machine, a shell script was created to run all the necessary commands in the appropriate order. This script makes the following assumptions:
1) The user has the following installed (at the bare minimum and in addition to other standard developer tools/packages):
    1) Homebrew
    2) Ruby 2.6.6
    3) Rails 5.2.0
    4) Github CLI
2) With regards to Github, the user has cloned the repo and is in the main folder using the commands below:
   ```
    git clone https://github.com/Betwork/betwork.git
    cd betwork
    ```

If the above is satisfied, the user need only run the following command to start the application locally:
```
bash setup.sh
```

In case the user would like to run the setup manually or understand the commands being run during the setup, they can refer to the code-block below where the contents of the `setup.sh` file are copied and explained.
```
# update homebrew itself
brew update

# upgrade all individual homebrew packages and formulae
brew upgrade
    
# install necessary dependencies of the gems of the application    
brew install shared-mime-info
brew install postgresql

# fetch all remote branches
git fetch

# stash any changes the user happened to make
git stash
    
# ensure that the user is on the latest stable branch (Iteration 2)
git checkout proj-launch

# ensure that the branch is up to date
git pull

# install all the Ruby Gems (modules) for Betwork
bundle install

# update all the Ruby Gems (modules) for Betwork
bundle update

# drop the database (if it existed)
rake db:drop

# run all the migrations on the db from the start
rake db:migrate

# populate the db with necessary information to start
rake fill:data

# run the rails server
rails server
```
It must be noted that while the above could work on a Windows machine, it has primarily been run on MacOS and hence has been configured as such.


## Heroku Deployment
Similar to the above, a shell script was added to automate the deployment of the application to Heroku. In addition to the requirements/assumptions outlined in the local deployment section above, this script makes the following assumptions:
1) The user has installed the Heroku CLI.
2) The user has a Heroku account with the ability to add at least 1 new application.
3) The user has logged into the Heroku CLI using `heroku login` or `heroku login -i`.
4) The user sign-up feature will not work for deployments to Heroku due to API KEY / Privacy requirements by Twilio's SendGrid solution/

If the above is satisfied, the user need only run the following command to deploy the application to Heroku:
```
bash heroku-deploy.sh
```

In case the user would like to run the deployment manually or understand the commands being run during the deployment, they can refer to the code-block below where the contents of the `heroku-deploy.sh` file are copied and explained.
```
# check if the Heroku app has been set up before in this repo by trying
# to open it in the browser
if heroku open; then
    # if it exists, nothing required
    echo "App exists"
else
    # if not, create the app with stack version = 20 
    # corresponding to our requirements
    heroku create --stack heroku-20
fi

# stash any changes the user made
git stash

# navigate to the master branch of the repo
git checkout master

# ensure that we are up to date with the branch
git pull

# push the master branch to heroku
git push heroku master

# run the necessary migrations (since the last time the db was migrated)
heroku run rake db:migrate

# populate the db with the required data
heroku run rake fill:data

# re-open the app now that it has been deployed
heroku open
```
It must be noted that while the above could work on a Windows machine, it has primarily been run on MacOS and hence has been configured as such.


## Testing
Apart from code examinations and extensive manual testing, the application also has an elaborate test suite.

### Cucumber
Run cucumber tests for users (signing in/up/out), friends, posts, likes, comments and betting using

```
rails g cucumber:install
If asked to overwrite, enter n for NO
rake db:migrate RAILS_ENV=test
bundle exec cucumber
```

At this point, *Cucumber Tests are providing over 87% coverage!*

Given the nature of the project and the template we leveraged to get up and running, we are very proud of the testing coverage here which primarily focuses on the new features we've developed.

### Rspec
Run RSPEC tests for users (parameter validation), friends, odds, betting, and posting using

```
rake spec
```

At this point, *Rake Tests are providing over 71% coverage!*

It must be noted that the features/functionality that we have tested apply solely to those that we deem relevant to our
application from the template used. For this reason, a pure coverage report of `cucumber` or `rspec` tests will not
paint an accurate picture as to the required.


## Future Development
Given the commitment of the team members to bettering this application over the course of its development cycle, the team has already started planning ahead for the next iteration.

### Upcoming Features
While the team will consider feedback from application users when solidifying the roadmap for the next iteration, some major features to look forward to are:
1) Users will be able to create Groups within which they can have their own Betwork Board and multi-person bets.
