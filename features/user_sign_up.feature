Feature: user can sign up account on Betwork

    As an avid sports user
    So that I can quickly create an account

    Background: We are on the home page and haven't created an account
        Given I am on the Betwork home page

    Scenario: Sign up successful
        When I go to the Sign up page
        And I fill in "Name" with "John Doe"
        And I fill in "Email" with "jd@betwork.com"
        And I fill in "Password" with "012345678"
        And I fill in "Password confirmation" with "012345678"
        When I press "Sign up"
        Then I should see "A message with a confirmation link has been sent to your email address"

    Scenario: Sign up with duplicate email
        When I go to the Sign up page
        And I fill in "Name" with "John Doe"
        And I fill in "Email" with "test@betwork.com"
        And I fill in "Password" with "012345678"
        And I fill in "Password confirmation" with "012345678"
        When I press "Sign up"
        When I go to the Betwork home page
        When I go to the Sign up page
        And I fill in "Name" with "John Doe"
        And I fill in "Email" with "test@betwork.com"
        And I fill in "Password" with "012345678"
        And I fill in "Password confirmation" with "012345678"
        When I press "Sign up"
        Then I should see "Email has already been taken"

    Scenario: Sign up with non-matching passwords
        When I go to the Sign up page
        And I fill in "Name" with "John Doe"
        And I fill in "Email" with "test@betwork.com"
        And I fill in "Password" with "012345678"
        And I fill in "Password confirmation" with "012345678999999"
        When I press "Sign up"
        Then I should see "Password confirmation doesn't match Password"

    Scenario: Sign up with blank password
        When I go to the Sign up page
        And I fill in "Name" with "John Doe"
        And I fill in "Email" with "test@betwork.com"
        And I fill in "Password confirmation" with "012345678999999"
        When I press "Sign up"
        Then I should see "Password can't be blank"

    Scenario: Sign up with blank name
        When I go to the Sign up page
        And I fill in "Email" with "test@betwork.com"
        And I fill in "Password" with "012345678"
        And I fill in "Password confirmation" with "012345678"
        When I press "Sign up"
        Then I should see "Name can't be blank"

    Scenario: Sign up with blank email
        When I go to the Sign up page
        And I fill in "Name" with "John Doe"
        And I fill in "Password" with "012345678"
        And I fill in "Password confirmation" with "012345678"
        When I press "Sign up"
        Then I should see "Email can't be blank"