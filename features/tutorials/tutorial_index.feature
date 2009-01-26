Feature: tutorial index
  To see what tutorials are available
  A user of merbunity
  Wants to see a list of recent tutorials 

  Scenario: Public Access
    Given 5 published tutorial articles
		And I am not authenticated
    When I go to /tutorials
    Then I should see a list of articles
    And the request should be successful
  
  Scenario: Logged in Access
    Given the default user exists
    Given 5 published tutorial articles
    And I login as fred with sekrit
    When I go to /tutorials
    Then I should see a list of articles
    And the request should be successful
  
  Scenario: No Articles Present
    Given no articles exist
    When I go to /tutorials
    Then there should be no articles
    And the request should be successful
