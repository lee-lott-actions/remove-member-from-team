# Remove Member to Team Action

This GitHub Action removes a GitHub user from a specified team in an organization using the GitHub API. It returns the result of the operation (`success` or `failure`) and an error message if the operation fails.

## Features
- Removes a user from a team in an organization via a PUT request to the GitHub API.
- Expects slugified usernames and team names for API compatibility.
- Outputs the result of the operation (`result`) and an error message if applicable.
- Requires a GitHub token with organization admin permissions.
- Includes debug logging to ensure step output visibility in the GitHub Actions UI.

## Inputs
| Name          | Description                                              | Required | Default   |
|---------------|----------------------------------------------------------|----------|-----------|
| `member-name` | The slugified username of the member to add (e.g., "john-doe"). | Yes      | N/A       |
| `team-name`   | The slugified name of the team (e.g., "code-approvers"). | Yes      | N/A       |
| `token`       | GitHub token with organization admin permissions.        | Yes      | N/A       |
| `owner`       | The owner of the organization (user or organization).    | Yes      | N/A       |

## Outputs
| Name           | Description                                              |
|----------------|----------------------------------------------------------|
| `result`       | Result of the remove member operation (`success` or `failure`). |
| `error-message`| Error message if the remove member operation fails.         |

## Usage
1. **Add the Action to Your Workflow**:
   Create or update a workflow file (e.g., `.github/workflows/remove-member-from-team.yml`) in your repository.

2. **Reference the Action**:
   Use the action by referencing the repository and version (e.g., `v1`).

3. **Example Workflow**:
   ```yaml
   name: Remove Member from Team
   on:
     workflow_dispatch:
       inputs:
         member-name:
           description: 'Slugified username of the member to be removed (e.g., "john-doe")'
           required: true
         team-name:
           description: 'Slugified name of the team (e.g., "code-approvers")'
           required: true

   jobs:
     remove-member:
       runs-on: ubuntu-latest
       steps:
         - name: Remove Member From Team
           id: remove-member
           uses: la-actions/remove-member-from-team@v1
           with:
             member-name: ${{ github.event.inputs.member-name }}
             team-name: ${{ github.event.inputs.team-name }}
             token: ${{ secrets.GITHUB_TOKEN }}
             owner: ${{ github.repository_owner }}
         - name: Print Result
           run: |
             if [[ "${{ steps.remove-member.outputs.result }}" == "success" ]]; then
               echo "Successfully added ${{ github.event.inputs.member-name }} to team ${{ github.event.inputs.team-name }}."
             else
               echo "Error: ${{ steps.remove-member.outputs.error-message }}"
               exit 1
             fi
