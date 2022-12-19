Feature: user can place bets

  As an avid social sports better
  So that I can place bets
  I want to find a bet to propose against my friend


# Bet functionality
Background: We are on the home page and haven't logged in yet
  Given the Betwork test database exists
  Given the admin user has money
  And I am on the Betwork login page
  And I fill in "user_email" with "test@betwork.com"
  And I fill in "user_password" with "password"
  And I press "Log in"

Scenario: I look for Live Bets
  Given I am on the Betwork home page
  When I follow "Live Bets"
  Then I should see "Propose Bet"

Scenario: I place a bet against my friend and look at my new bet
  Given my test friend exists
  And the admin user has money
  And I am on the Betwork find friends page
  # Add Betty to friends list
  When I last press follow

  # Go to Live Bets to bet against her
   And I follow "Live Bets"
   And I place a bet on the first game
   Then I should see "Betty"

  # I place the bet against Betty
  And I first press place bet
  Then I should see "Confirm Your Betting Details"
  And I should see "Betty"
  Then I fill in "bet_amount" with "50"
  And I press "Confirm Proposition"
  Then I sleep
  Then I should see "Your bet has been proposed!"

  # I look at my new bet
  And I am on the Betwork home page
  And I follow "My Bets"
  Then I should see "Your Confirmed Bets"
  And I should see "Betty"
  And I should see "50"
  #Cancel 
  And I cancel my bet
  And I am on the Betwork home page 
  And I follow "My Bets"
  Then I should see "Your Cancelled Bets"


Scenario: Accept a bet (this bet will already be finished, to simulate finished games auto completing)
  Given my test friend exists
  And the admin user has money
  And I am on the Betwork find friends page 
  When I last press follow 
  # Go to Live Bets to bet against her
  And I follow "Live Bets"
  And I place a bet on the first game
  Then I should see "Betty"

  # I place the bet against Betty
  And I first press place bet
  Then I should see "Confirm Your Betting Details"
  And I should see "Betty"
  Then I fill in "bet_amount" with "50"
  And I press "Confirm Proposition"
  Then I sleep
  Then I should see "Your bet has been proposed!"

  # Sign in as Betty and Accept a already finished bet to simulate "Finished Game"
  And I am on the Betwork home page 
  Then I navigate to the dropdown-menu
  Then I sign out of Betwork
  Given I am on the Betwork login page
  When I fill in "user_email" with "Betty@betwork.com"
  And I fill in "user_password" with "password"
  When I press "Log in"
  Given I am on the Betwork home page
  And I follow "My Bets"
  And I accept a proposed bet 
  And I am on the Betwork home page 
  And I follow "My Bets"




Scenario: Accept a bet (this bet will already be finished, to simulate finished games auto completing, choose other game)
  Given my test friend exists
  And the admin user has money
  And I am on the Betwork find friends page 
  When I last press follow 
  # Go to Live Bets to bet against her
  And I follow "Live Bets"
  And I place a bet on the first game
  Then I should see "Betty"

  # I place the bet against Betty
  And I first press place bet
  Then I should see "Confirm Your Betting Details"
  And I should see "Betty"
  Then I fill in "bet_amount" with "50"
  And I change teams to "OKC"
  And I press "Confirm Proposition"
  Then I sleep
  Then I should see "Your bet has been proposed!"

  # Sign in as Betty and Accept a already finished bet to simulate "Finished Game"
  And I am on the Betwork home page 
  Then I navigate to the dropdown-menu
  Then I sign out of Betwork
  Given I am on the Betwork login page
  When I fill in "user_email" with "Betty@betwork.com"
  And I fill in "user_password" with "password"
  When I press "Log in"
  Given I am on the Betwork home page
  And I follow "My Bets"
  And I accept a proposed bet 
  And I am on the Betwork home page 
  And I follow "My Bets"
