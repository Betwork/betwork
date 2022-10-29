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


