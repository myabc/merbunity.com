Feature: View a tutorial
  A Visitor to the site
  Should be able to view a news article
  So that they get benefit from the content on the site
  So that the site is relevant

  Scenario: A public visitor views a published tutorial
    Given the default user exists
    And a published Tutorial article with slug "foo-bar" and owned by "fred"
    When I go to /tutorials/foo-bar
    Then I should see an article
    And the request should be successful

  Scenario: A public visitor views a non existent tutorial
    Given no articles exist
    When I go to /tutorials/i-dont-exist
    Then the response should be missing

  Scenario: A Logged in user should be able to view the tutorial
    Given the following users exist:
      | login   | password |
      | fred    | sekrit   |
      | barney  | foo      |
    And a published Tutorial article with slug "a-slug" and owned by "fred"
    And I login as barney with foo
    When I go to /tutorials/a-slug
    Then I should see an article
    And the request should be successful
