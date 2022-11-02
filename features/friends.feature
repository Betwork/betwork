Feature: user can see their friends

    As an avid social sports better
    So that I can quickly find my friends to bet with
    I want to be able to see a list of friends to add, my friends, and be able to add/remove friends

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

# This scenario is combined events to prevent redundancy
Scenario: I add a new friend, see my new friend, and remove my new friend
    Given my test friend exists
    And I am on the Betwork find friends page
    # this is pressing the follow button for the last result which is our test user Betty
    When I last press follow
    # After pressing follow I should see unfollow button
    Then I should see "unfollow"
    # Go to my friends
    When I follow "Friends"
    # I should see Betty
    Then I should see "Betty"
    # Unfollow (unfriend) Betty
    When I press "unfollow"
    # "Refresh" the page by going to the page again
    Then I follow "Friends"
    # See that I have no friends :(
    Then I should see "No Friends found."