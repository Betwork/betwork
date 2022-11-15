Feature: user can add funds to their account

  As an avid social sports better
  So that I can place bets and make money
  I need to fund my account with money, check my balance after placing bets, and withdraw money

Background: We are on the home page and haven't logged in yet
  Given the Betwork test database exists
  And I am on the Betwork login page
  And I fill in "user_email" with "test@betwork.com"
  And I fill in "user_password" with "password"
  And I press "Log in"

Scenario: I deposit funds
  Given I am on the Betwork home page
  When I follow "Manage Funds"
  And I balance form select "Add"
  And I fill in "balance_change" with "500"
  And I press "Submit"
  Then I should see "500.0 dollars"

Scenario: I deposit a non numeric value
  Given I am on the Betwork home page
  When I follow "Manage Funds"
  And I balance form select "Add"
  And I fill in "balance_change" with "f"
  And I press "Submit"
  Then I should see "0.0 dollars"
  And I should see "Invalid input, please input a number greater than zero"

Scenario: I deposit a negative value
  Given I am on the Betwork home page
  When I follow "Manage Funds"
  And I balance form select "Add"
  And I fill in "balance_change" with "-10"
  And I press "Submit"
  Then I should see "0.0 dollars"
  And I should see "Invalid input, please input a number greater than zero"

Scenario: I withdraw funds
  Given I am on the Betwork home page
  # $500
  And the admin user has money
  And I follow "Manage Funds"
  And I balance form select "Withdraw"
  And I fill in "balance_change" with "400"
  And I press "Submit"
  Then I should not see "500.0 dollars"
  And I should see "100.0 dollars"

Scenario: I withdraw more money than I have
  Given I am on the Betwork home page
  # $500
  And the admin user has money
  And I follow "Manage Funds"
  And I balance form select "Withdraw"
  And I fill in "balance_change" with "600"
  And I press "Submit"
  Then I should see "500.0 dollars"
  And I should see "Cannot withdraw more than your Actual Balance minus Pending Bets"

Scenario: I withdraw negative value
  Given I am on the Betwork home page
  # $500
  And the admin user has money
  And I follow "Manage Funds"
  And I balance form select "Withdraw"
  And I fill in "balance_change" with "-100"
  And I press "Submit"
  Then I should see "500.0 dollars"
  And I should see "Invalid input, please input a number greater than zero"

Scenario: I withdraw non numeric value
  Given I am on the Betwork home page
  # $500
  And the admin user has money
  And I follow "Manage Funds"
  And I balance form select "Withdraw"
  And I fill in "balance_change" with "f"
  And I press "Submit"
  Then I should see "500.0 dollars"
  And I should see "Invalid input, please input a number greater than zero"

Scenario: I go to view my funds with a pending bet placed
#   Need to add money, propose a bet, navigate to page
  Given I am on the Betwork home page
  And the admin user has money
  And my test friend exists
  # $50 STUCK ON THIS STEP
  And I have placed a bet
  And I follow "My Bets"
  Then I should see "450.0 dollars"
  And I should see "50.0 dollars"
  And I sleep