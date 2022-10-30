Feature: user can log in to Betwork

    As an avid sports user
    So that I can quickly create an account 
    I want to be able to log in 

Background: We are on the home page and haven't logged in yet
    Given I am on the Betwork login page
    Given the admin user exists 
    Then I should see "Log in"

Scenario: We enter a valid username and password and should be able to log in
    When I fill in "user_email" with "test@betwork.com"
    And I fill in "user_password" with "password"
    When I press "Log in" 
    Then I should not see "Log in"
    And I should not see "Invalid"

Scenario: We enter an invalid username and password and should not be able to log in 
    When I fill in "user_email" with "fake@notreal.com"
    And I fill in "user_password" with "not real"
    When I press "Log in"
    Then I should see "Invalid"

Scenario: We are able to succesfully log out
    When I fill in "user_email" with "test@betwork.com"
    And I fill in "user_password" with "password"
    When I hit return
    Then I should not see "Log in"
    And I take a screenshot
    And I should see "Invalid"
    Then I navigate to the dropdown-menu
    Then I press "Log Out" 
    Then I should see "Signed out. Bye!"

