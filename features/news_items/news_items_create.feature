Feature: Create An Article
  A user of merbunity
  Should be able to create new articles
  So that there is a good way to add content to the site
  So that the community gains benefit
  
  Scenario: Visiting the new form to create a new article when not logged in
    When I go to /news_items/new
    Then I should require authentication
    And I should see the login form
  
  Scenario: Visiting the new form when logged in
    Given the default user exists
    And I login as fred with sekrit
    When I go to /news_items/new
    Then I should see a form to create new news items
    And I should see form fields for a news_item article
    And the request should be successful
  
  Scenario: Creating a new news item draft when  logged in
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
    
  Scenario: Creating a published news item when logged in
    Given the default user exists
    And I login as fred with sekrit
    And no news_items exist
    When I go to /news_items/new
    And I fill in "title" with "My Awesome Title"
    And I fill in "description" with "My Awesome Description"
    And I fill in "body" with "My Awesome Body"
    And I press "Publish"
    Then I should see the page /news_items/my-awesome-title
    And I should not see that the news item is a draft
    And the request should be successful

    
  Scenario: Creating a new news item by posting directly when not logged in
    When I POST directly to /news_items with params:
      | name                    | value         |
      | news_item[title]        | A Title       |
      | news_item[description]  | A description |
      | news_item[body]         | A body        |
    Then I should require authentication
  
  Scenario: Creating a new news item by posting directly when logged in
    Given no articles exist
    And the default user exists
    And I login as fred with sekrit
    When I POST directly to /news_items with params:
      | name                    | value         |
      | news_item[title]        | A Title       |
      | news_item[description]  | A description |
      | news_item[body]         | A body        |
    Then I should be redirected to /news_items/a-title
  
  Scenario: Creating an incomplete news item
    Given no articles exist
    And the default user exists
    And I login as fred with sekrit
    When I go to /news_items/new
    And I fill in "body" with "My Body"
    And I press "Save"
    Then I should see a form to create new news items
    And the request should be in conflict 
  
  
