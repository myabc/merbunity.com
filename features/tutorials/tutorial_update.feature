Feature: Edit Tutorial
  A user of merbunity
  To ensure good content to benefit the community
  I want to be able to edit and update a Tutorial

  Scenario: Public Access
    Given a published Tutorial article with slug "a-title" and owned by "fred"
    When I go to /tutorials/a-title/edit
    Then I should require authentication
    And I should see the login form

  Scenario: Owner Access
    Given the default user exists
    Given a published Tutorial article with slug "a-title" and owned by "fred"
    And I login as fred with sekrit
    When I go to /tutorials/a-title/edit
    Then I should see a form to edit tutorial a-title
    And I should see form fields for a tutorial article
    And the request should be successful

  Scenario: Owner Access with an update
    Given the default user exists
    Given a published Tutorial article with slug "a-title" and owned by "fred"
    And I login as fred with sekrit
    When I go to /tutorials/a-title/edit
    And I fill in "title" with "A New Title"
    And I fill in "description" with "A New Description"
    And I press "Publish"
    Then I should see the page /tutorials/a-title
    And the request should be successful

  Scenario: A direct PUT to try to update an article when not logged in
    Given the default user exists
    And a published Tutorial article with slug "a-title" and owned by "fred"
    When I PUT directly to /tutorials/a-title with params:
      | name              | value |
      | tutorial[title]  | A New Title |
    Then I should require authentication
    And I should see the login form

  Scenario: A director PUT to update an article when logged in as a non owner
    Given the following users exist:
      | login   | password |
      | fred    | sekrit   |
      | barney  | foo      |
    And a published Tutorial article with slug "a-slug" and owned by "fred"
    And I login as barney with foo
    When I PUT directly to /tutorials/a-slug with params:
      | name              | value       |
      | tutorial[title]  | A New Title |
    Then I should be forbidden

  Scenario: A direct PUT to update an article when logged in as the owner
    Given the default user exists
    And I login as fred with sekrit
    And a published Tutorial article with slug "a-slug" and owned by "fred"
    When I PUT directly to /tutorials/a-slug with params:
      |name               |  value      |
      | tutorial[title]  | A New Title |
    Then I should be redirected to /tutorials/a-slug

  Scenario: Non Owner Editing An Article
  Given the following users exist:
    | login   | password |
    | fred    | sekrit   |
    | barney  | foo      |
  And a published Tutorial article with slug "foo-bar" and owned by "fred"
  And I login as barney with foo
  When I go to /tutorials/foo-bar/edit
  Then I should be forbidden

  Scenario: Editing and saving as a draft
    Given the default user exists
    And I login as fred with sekrit
    And no Tutorial exist
    And no tutorial exist with drafts
    And a published Tutorial article with slug "my-slug" and owned by "fred"
    When I go to /tutorials/my-slug/edit
    And I fill in "title" with "My Foo"
    And I fill in "description" with "My Foo Description"
    And I press "Save Draft"
    Then I should see the page /tutorials/my-slug/draft
    And the tutorial title should be "My Foo"
    And the tutorial should have a description "My Foo Description"
    And the request should be successful

  Scenario: Viewing a published article after saving a draft
    GivenScenario Editing and saving as a draft
    When I go to /tutorials/my-slug
    Then the tutorial title should not be "My Foo"
    And the tutorial should not have a description "My Foo Description"
    And the request should be successful

  Scenario: When Editing An existing Draft It should save the new value
    GivenScenario Editing and saving as a draft
    When I go to /tutorials/my-slug/edit
    Then I should see a "tutorial[title]" field with attribute value "My Foo"
    And I should see a "tutorial[description]" field containing text "My Foo Description"
    When I fill in "title" with "A New Foo"
    And I press "Save Draft"
    Then I should see the page /tutorials/my-slug/draft
    And the tutorial title should be "A New Foo"
    And the request should be successful
