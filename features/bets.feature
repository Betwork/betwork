Feature: user can place bets

    As an avid social sports better
    So that I can quickly place bets
    I want to be able to see a list of bets I can place

# Friends functionality, want to have it so they can find new friends, add a new friend, view this friend, remove friend
Background: We are on the home page and haven't logged in yet
    Given the Betwork test database exists
    And I am on the Betwork login page
    And I fill in "user_email" with "test@betwork.com"
    And I fill in "user_password" with "password"
    And I press "Log in"

Scenario: I look for a new friend
    Given my test friend exists
    And I am on the Betwork home page
    When I follow "Find Friends"
    Then I should see "Betty"

