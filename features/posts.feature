Feature: A user can post on the Betwork Board
    As an avid sports fan
    I want to be able to post on the Betwork Board
    So I can share my thoughts and pics with friends!

Background:
    Given I am on the Betwork login page
    And the Betwork test database exists
    Then I should see "Log in"




Scenario: We log in and try to post 
        When I fill in "user_email" with "test@betwork.com"
        And I fill in "user_password" with "password"
        When I press "Log in"
        Given I am on the Betwork home page
        Then I should not see "Log in"
        And I should not see "Invalid"
        When I create a new post
        And I fill in the post with some text "this is a great test!"
        And I press "Post"
        Then I should see "this is a great test!"
        Then I delete my post 
        Then I should not see "this is a great test!"


        #Post and comment 
        Then I create a new post 
        And I fill in the post with some text "testing out comments now!" 
        And I press "Post"
        Then I should see "testing out comments now!"
        Then I add a comment to the post 
        And I create a new comment 
        And I fill in the comment with some text "wow that is a pretty good comment"
        And I click the comment button
        Then I should see "wow that is a pretty good comment"
        And I like the post from the posts page 
        And I unlike the post from the posts page
