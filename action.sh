#!/bin/bash

remove_member_from_team() {
  local member_name="$1"
  local team_name="$2"
  local token="$3"
  local owner="$4"

  if [ -z "$member_name" ] || [ -z "$team_name" ] || [ -z "$token" ] || [ -z "$owner" ]; then
    echo "Error: Missing required parameters"
    echo "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided." >> "$GITHUB_OUTPUT"
    echo "result=failure" >> "$GITHUB_OUTPUT"
    return
  fi

  echo "Attempting to remove member '$member_name' from team '$team_name' in organization '$owner'"

  # Use MOCK_API if set, otherwise default to GitHub API
  local api_base_url="${MOCK_API:-https://api.github.com}"

  # Add member to the team with specified role using GitHub API
  RESPONSE=$(curl -s -L \
    -w "%{http_code}" \
    -X DELETE \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $token" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Content-Type: application/json" \
    -o response_body.json \
    "$api_base_url/orgs/$owner/teams/$team_name/memberships/$member_name")

  if [ "$RESPONSE" -eq 204 ]; then
    echo "Successfully remove $member_name from team $team_name"
    echo "result=success" >> "$GITHUB_OUTPUT"
  else
    echo "Error: Failed to remove $member_name from team $team_name. HTTP Status: $RESPONSE"
    echo "error-message=Failed to remove member $member_name from team $team_name. HTTP Status: $RESPONSE" >> "$GITHUB_OUTPUT"
    echo "result=failure" >> "$GITHUB_OUTPUT"
  fi

  # Clean up temporary file
  rm -f response_body.json
}
