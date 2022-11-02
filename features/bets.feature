Feature: user can place bets

  As an avid social sports better
  So that I can quickly place bets
  I want to be able to see a list of bets I can place and have placed

# Bet functionality
Background: We are on the home page and haven't logged in yet
  Given the Betwork test database exists
  And I am on the Betwork login page
  And I fill in "user_email" with "test@betwork.com"
  And I fill in "user_password" with "password"
  And I press "Log in"

Scenario: I look for Live Bets
  Given I am on the Betwork home page
  When I follow "Live Bets"
  Then I should see "New York Knicks"
  And I should see "Los Angeles Lakers"
  And I should see "-110"

Scenario: I place a bet against my friend and look at my new bet
  Given my test friend exists
  And I am on the Betwork find friends page
  # Add Betty to friends list
  When I last press follow

  # Go to Live Bets to bet against her
  And I follow "Live Bets"
  And I place a bet on the first game
  Then I should see "Betty"

  # I place the bet against Betty
  And I first press place bet
  Then I should see "Confirm Your Bettings Details"
  And I should see "New York Knicks"
  And I should see "Los Angeles Lakers"
  And I should see "-110"
  And I should see "Betty"
  Then I fill in "bet_amount" with "50"
  And I press "Confirm Bet"
  Then I should see "Your bet has been confirmed!"

  # I look at my new bet
  And I am on the Betwork home page
  And I follow "My Bets"
  Then I should see "Your Bets"
  And I should see "Los Angeles Lakers"
  And I should see "New York Knicks"
  And I should see "Betty"
  And I should see "50"
  And I should see "-110"



