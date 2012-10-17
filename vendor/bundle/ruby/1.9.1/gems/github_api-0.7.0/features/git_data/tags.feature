Feature: Tags API

  In order to interact with github git data references
  GithubAPI gem
  Should return the expected results depending on passed parameters

  Background:
    Given I have "Github::GitData::Tags" instance

#   Scenario: Lists all tags on a repository
#     Given I want to get resource with the following params:
#       | user   | repo | sha |
#       | wycats | thor | 54cbeb8591609aa949212c8988a08741008c9ade |
#     When I make request within a cassette named "git_data/tags/get"
#     Then the response status should be 200
#       And the response type should be JSON
#       And the response should not be empty
