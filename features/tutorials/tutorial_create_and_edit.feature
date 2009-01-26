Feature: Create Then Edit Tutorial
  Someone with permission should be able to create then edit
  so that a publisher can draft good content
  so that the site remains focused and valid
  so that the site is valuable to the community
  
  Scenario Creating a new tutorial draft when  logged in
    Given the default user exists
    And no tutorials exist
    And no tutorials exist with drafts
    And I login as fred with sekrit
    When I go to /tutorials/new
    And I fill in "title" with "My Awesome Title"
    And I fill in "description" with "My Awesome Description"
    And I fill in "body" with "My Awesome Body"
    And I press "Save Draft"
    Then I should see the page /tutorials/my-awesome-title/draft
    And I should see that the tutorial is a draft
    And the request should be successful
    
  Scenario Editing a tutorial draft that has never been published
    GivenScenario Creating a new tutorial draft when  logged in
    When I go to /tutorials/my-awesome-title/draft
    Then the tutorial title should be "My Awesome Title"
    And the tutorial should have a description "My Awesome Description"
  
  Scenario Showing a tutorial that has not been published
    GivenScenario Creating a new tutorial draft when  logged in
    When I go to /tutorials/my-awesome-title
    Then I should see the page /tutorials/my-awesome-title/draft