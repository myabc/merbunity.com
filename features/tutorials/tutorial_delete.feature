Feature: Delete a Tutorial
  Someone with permission should be able to delete a tutorial
  so that crap content can be removed
  so that the site remains focused and valid
  so that the site is valuable to the community

  Scenario: A Public user tries to delete a published tutorial
    Given the default user exists
    And a published Tutorial article with slug "foo" and owned by "fred"
    When I go to /tutorials/foo/delete
    Then I should require authentication

  Scenario: A public user tries to directly delete a published tutorial
    Given the default user exists
    And a published Tutorial article with slug "foo" and owned by "fred"
    When I DELETE directly to /tutorials/foo without params
    Then I should require authentication

  Scenario: A logged in user who does own the published item tries to visit the delete form
    Given the default user exists
    And a published Tutorial article with slug "goo" and owned by "fred"
    And I login as fred with sekrit
    When I go to /tutorials/goo/delete
    Then I should see a delete form for /tutorials/goo
    And the request should be successful

  Scenario: A logged in use who owns the item visits the delete form deletes the item
    Given no articles exist
    Given the default user exists
    And a published Tutorial article with slug "goo" and owned by "fred"
    And I login as fred with sekrit
    When I go to /tutorials/goo/delete
    And I press "Delete"
    Then I should see the page /tutorials
    And the Tutorial with slug "goo" should not exist
    And the request should be successful

  Scenario: A logged in user who does not own the item visits the delete form
    Given no articles exist
    And the following users exist:
      | login   | password |
      | fred    | sekrit   |
      | barney  | foo      |
    And I login as barney with foo
    And a published tutorial article with slug "bar" and owned by "fred"
    When I go to /tutorials/bar/delete
    Then I should be forbidden

  Scenario: A logged in user who does not own the item deletes the item directly
    Given no articles exist
    And the following users exist:
      | login   | password |
      | fred    | sekrit   |
      | barney  | foo      |
    And I login as barney with foo
    And a published tutorial article with slug "bar" and owned by "fred"
    When I DELETE directly to /tutorials/bar without params
    Then I should be forbidden
