function Remove-MemberFromTeam {
    param(
        [string]$MemberName,
        [string]$TeamName,
        [string]$Token,
        [string]$Owner
    )

    # Validate required parameters
    if ([string]::IsNullOrEmpty($MemberName) -or
        [string]::IsNullOrEmpty($TeamName) -or
        [string]::IsNullOrEmpty($Token) -or
        [string]::IsNullOrEmpty($Owner)) {
        Write-Output "Error: Missing required parameters"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided."
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        return
    }

    Write-Host "Attempting to remove member '$MemberName' from team '$TeamName' in organization '$Owner'"

    # Use MOCK_API if set, otherwise default to GitHub API
    $apiBaseUrl = $env:MOCK_API
    if (-not $apiBaseUrl) { $apiBaseUrl = "https://api.github.com" }
    $uri = "$apiBaseUrl/orgs/$Owner/teams/$TeamName/memberships/$MemberName"

    $headers = @{
        Authorization = "Bearer $Token"
        Accept = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2026-03-10"
    }

    try {
        Write-Host "Sending DELETE request to $uri"
        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Delete

        if ($response.StatusCode -eq 204) {
            Write-Host "Successfully removed $MemberName from team $TeamName"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
        } else {
            Write-Host "Error: Failed to remove $MemberName from team $TeamName. HTTP Status: $($response.StatusCode)"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Failed to remove member $MemberName from team $TeamName. HTTP Status: $($response.StatusCode)"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        }
    } catch {
		$errorMsg = "Error: Failed to remove $MemberName from team $TeamName. Exception: $($_.Exception.Message)"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
		Write-Host $errorMsg
    }
}
