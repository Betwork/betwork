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
    Given the Betwork test database exists
    And I am on the Betwork home page
    When I follow "Live Bets"
    Then I should see "Home Team"
    And I should see "Away Team"
    And I should see "Odds"
    And I should see "Place Bets"

Scenario: I look for My Bets
    Given the Betwork test database exists
    And I am on the Betwork home page
    When I follow "My Bets"
    Then I should see "Home Team"
    And I should see "Away Team"
    And I should see "Odds"
    And I should see "Amount"
    And I should see "Betting Against"


