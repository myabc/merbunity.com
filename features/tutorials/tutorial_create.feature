Feature: Create An Tutorial
  A user of merbunity
  Should be able to create new articles
  So that there is a good way to add content to the site
  So that the community gains benefit

  Scenario: Visiting the new form to create a new article when not logged in
    When I go to /tutorials/new
    Then I should require authentication
    And I should see the login form

  Scenario: Visiting the new form when logged in
    Given the default user exists
    And I login as fred with sekrit
    When I go to /tutorials/new
    Then I should see a form to create new tutorials
    And I should see form fields for a tutorial article
    And the request should be successful

    Scenario: Creating a new tutorial draft when  logged in
      Given the default user exists
      And I login as fred with sekrit
      When I go to /tutorials/new
      And I fill in "title" with "My Awesome Title"
      And I fill in "description" with "My Awesome Description"
      And I fill in "body" with "My Awesome Body"
      And I press "Save Draft"
      Then I should see the page /tutorials/my-awesome-title/draft
      And I should see that the tutorial is a draft
      And the request should be successful

    Scenario: Creating a published tutorial when logged in
      Given the default user exists
      And I login as fred with sekrit
      And no tutorials exist
      And no tutorials exist with drafts
      When I go to /tutorials/new
      And I fill in "title" with "My Awesome Title"
      And I fill in "description" with "My Awesome Description"
      And I fill in "body" with "My Awesome Body"
      And I press "Publish"
      Then I should see the page /tutorials/my-awesome-title
      And I should not see that the tutorial is a draft
      And the request should be successful

  Scenario: Creating a new tutorial by posting directly when not logged in
    When I POST directly to /tutorials with params:
      | name                    | value         |
      | tutorial[title]        | A Title       |
      | tutorial[description]  | A description |
      | tutorial[body]         | A body        |
    Then I should require authentication

  Scenario: Creating a new tutorial by posting directly when logged in
    Given no articles exist
    And the default user exists
    And I login as fred with sekrit
    When I POST directly to /tutorials with params:
      | name                    | value         |
      | tutorial[title]        | A Title       |
      | tutorial[description]  | A description |
      | tutorial[body]         | A body        |
    Then I should be redirected to /tutorials/a-title

  Scenario: Creating an incomplete tutorial
    Given no articles exist
    And the default user exists
    And I login as fred with sekrit
    When I go to /tutorials/new
    And I fill in "body" with "My Body"
    And I press "Save"
    Then I should see a form to create new tutorials
    And the request should be in conflict
