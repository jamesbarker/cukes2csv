Feature: Browse
  As a user
  I would like to browse content
  So I can see what the content the app offers

  Scenario: Browse though promotional content
    Given I am on the "Home" screen
    When I click on the "Promotion Gallery"
    Then I can browse though content

  @wip @smoke
  Scenario: Browse though all content
    Given I am on the "Home" screen
    When I click on the "Browse All" button
    Then I can browse though all the content


