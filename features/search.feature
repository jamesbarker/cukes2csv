Feature: Search
  As a user
  I would like to search content
  So I can quickly find content

  @smoke
  Scenario: Simple Search
    Given I am on the "search" screen
    When I search for "books"
    Then I am shown results relevant to "books"

  @wip
  Scenario Outline: Complex Search
    Given I am on the "search" screen
    When I search for "<search>"
    Then I am shown results relevant to "<search>"
  Examples:
    |search              |
    |outdoor & recreation|
    |a very long test    |
    |beep                |