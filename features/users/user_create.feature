Feature: Signup for an account
  People should be able to sign up for an account
  so they can participate on merbunity
  so that the site is a community site
  
  Scenario: A public user visits the new user page
    When I go to /people/new
    Then I should see a form to create new people
    And I should see fields for a person form
    And the request should be successful
  
  Scenario: A public user visits the signup page
    When I go to /signup
    Then I should see a form to create new people
    And I should see fields for a person form
    And the request should be successful
  
  Scenario: A logged in user visits the new user page
    Given the default user exists
    And I login as fred with sekrit
    When I go to /people/new
    Then I should see the page /people/fred
    And the request should be successful
  
  Scenario: A public user visits the new form and fills it out
    Given no users exist
    When I go to /people/new
    And I fill in "login" with "jenny"
    And I fill in "password" with "password"
    And I fill in "password confirmation" with "password"
    And I press "Save"
    Then I should see the page /people/jenny
    And the request should be successful
  
  Scenario: A public user visits the site and fills in the form with a duplicate login
    GivenScenario A public user visits the new form and fills it out
    And I logout
    When I go to /people/new
    And I fill in "login" with "jenny"
    And I fill in "password" with "password"
    And I fill in "password confirmation" with "password"
    And I press "Save"
    Then the request should be in conflict
    And I should see a form to create new people
    And I should see fields for a person form