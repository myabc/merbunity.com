Feature: news item index
  To see what news items are available
  A user of merbunity
  Wants to see a list of recent news items 

  Scenario: Public Access
    Given 5 published news item articles
		And I am not authenticated
    When I go to /news_items
    Then I should see a list of articles
    And the request should be successful
  
  Scenario: Logged in Access
    Given the following users exist:
      | login | password | 
      | fred  | sekrit   |
    Given 5 published news item articles
    And I login as fred with sekrit
    When I go to /news_items
    Then I should see a list of articles
    And the request should be successful
  
  Scenario: No Articles Present
    Given no articles exist
    When I go to /news_items
    Then I should see an empty articles list
    And the request should be successful
    