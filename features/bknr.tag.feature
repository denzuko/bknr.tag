Feature: Many-to-many labeling for persistent objects
  As a caller of bknr.tag
  I want to attach labels to persistent objects
  So that I can find every object with a given label without scanning the whole store

  Background:
    Given a fresh bknr.tag store

  Scenario: Adding a tag makes an object findable by that tag
    When I create an object called "a"
    And I tag "a" with "urgent"
    Then "a" should be findable by tag "urgent"

  Scenario: An object can carry more than one tag
    When I create an object called "a"
    And I tag "a" with "urgent"
    And I tag "a" with "billing"
    Then "a" should be findable by tag "urgent"
    And "a" should be findable by tag "billing"

  Scenario: Two objects can share a tag
    When I create an object called "a"
    And I create an object called "b"
    And I tag "a" with "urgent"
    And I tag "b" with "urgent"
    Then the objects tagged "urgent" should be "a" and "b"

  Scenario: Removing a tag stops an object from being found by it
    When I create an object called "a"
    And I tag "a" with "urgent"
    And I untag "a" with "urgent"
    Then "a" should not be findable by tag "urgent"

  Scenario: Removing one tag leaves other tags on the same object intact
    When I create an object called "a"
    And I tag "a" with "urgent"
    And I tag "a" with "billing"
    And I untag "a" with "urgent"
    Then "a" should not be findable by tag "urgent"
    And "a" should be findable by tag "billing"

  Scenario: Adding the same tag twice does not duplicate it
    When I create an object called "a"
    And I tag "a" with "urgent"
    And I tag "a" with "urgent"
    Then "a" should have exactly 1 tag
