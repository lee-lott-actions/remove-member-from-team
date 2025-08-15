#!/usr/bin/env bats

# Load the Bash script
load ../action.sh

# Mock the curl command to simulate API responses
mock_curl() {
  local http_code=$1
  local response_file=$2
  echo "$http_code"
  cat "$response_file" > response_body.json
}

# Setup function to run before each test
setup() {
  export GITHUB_OUTPUT=$(mktemp)
}

# Teardown function to clean up after each test
teardown() {
  rm -f response_body.json "$GITHUB_OUTPUT" mock_response.json
}

@test "remove_member_from_team succeeds with HTTP 204" {
  echo '' > mock_response.json
  curl() { mock_curl "204" mock_response.json; }
  export -f curl

  run remove_member_from_team "test-user" "test-team" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=success" ]
}

@test "remove_member_from_team fails with HTTP 404 (team or user not found)" {
  echo '{"message": "Not Found"}' > mock_response.json
  curl() { mock_curl "404" mock_response.json; }
  export -f curl

  run remove_member_from_team "test-user" "test-team" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Failed to remove member test-user from team test-team. HTTP Status: 404" ]
}

@test "remove_member_from_team fails with empty member_name" {
  run remove_member_from_team "" "test-team" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided." ]
}

@test "remove_member_from_team fails with empty team_name" {
  run remove_member_from_team "test-user" "" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided." ]
}

@test "remove_member_from_team fails with empty token" {
  run remove_member_from_team "test-user" "test-team" "" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided." ]
}

@test "remove_member_from_team fails with empty owner" {
  run remove_member_from_team "test-user" "test-team" "fake-token" ""

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided." ]
}
