Feature: Create Then Edit News Item
  Someone with permission should be able to create then edit
  so that a publisher can draft good content
  so that the site remains focused and valid
  so that the site is valuable to the community

  Scenario Creating a new news item draft when  logged in
    Given the default user exists
    And no news_items exist
    And no news_items exist with drafts
    And I login as fred with sekrit
    When I go to /news_items/new
    And I fill in "title" with "My Awesome Title"
    And I fill in "description" with "My Awesome Description"
    And I fill in "body" with "My Awesome Body"
    And I press "Save Draft"
    Then I should see the page /news_items/my-awesome-title/draft
    And I should see that the news item is a draft
    And the request should be successful

  Scenario Editing a news item draft that has never been published
    GivenScenario Creating a new news item draft when  logged in
    When I go to /news_items/my-awesome-title/draft
    Then the news item title should be "My Awesome Title"
    And the news item should have a description "My Awesome Description"

  Scenario Showing a news item that has not been published
    GivenScenario Creating a new news item draft when  logged in
    When I go to /news_items/my-awesome-title
    Then I should see the page /news_items/my-awesome-title/draft
