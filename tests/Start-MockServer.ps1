param(
    [int]$Port = 3000
)

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()

Write-Host "Mock server listening on http://127.0.0.1:$Port..." -ForegroundColor Green

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $path = $request.Url.LocalPath
        $method = $request.HttpMethod
        
        Write-Host "Mock intercepted: $method $path" -ForegroundColor Cyan

        $responseJson = $null
        $statusCode = 200

        # HealthCheck endpoint: GET /HealthCheck
        if ($method -eq "GET" -and $path -eq "/HealthCheck") {
            $statusCode = 200
            $responseJson = @{ status = "ok" } | ConvertTo-Json
        }
        # DELETE /orgs/:owner/teams/:team_slug/memberships/:username
        elseif ($method -eq "DELETE" -and $path -match '^/orgs/([^/]+)/teams/([^/]+)/memberships/([^/]+)$') {
            $owner = $Matches[1]
            $teamSlug = $Matches[2]
            $username = $Matches[3]
            $headers = $request.Headers
            Write-Host "Request headers: $($headers | Out-String)"

            if ($owner -eq "test-owner" -and $teamSlug -eq "test-team" -and $username -eq "test-user") {
                $statusCode = 204
                # Response body should be empty for 204
                $responseJson = $null
            }
            elseif ($username -eq "non-existing-user") {
                $statusCode = 404
                $responseJson = @{ message = "Not Found: User is not a member of the team" } | ConvertTo-Json
            }
            elseif ($teamSlug -eq "non-existing-team") {
                $statusCode = 404
                $responseJson = @{ message = "Not Found: Team does not exist" } | ConvertTo-Json
            }
            else {
                $statusCode = 404
                $responseJson = @{ message = "Not Found: Team or user does not exist" } | ConvertTo-Json
            }
        }
        else {
            $statusCode = 404
            $responseJson = @{ message = "Not Found" } | ConvertTo-Json
        }

        # Send response
        $response.StatusCode = $statusCode
        if ($statusCode -eq 204) {
            $response.ContentLength64 = 0
            $response.OutputStream.Close()
        } else {
            $response.ContentType = "application/json"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseJson)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()
        }
    }
}
finally {
    $listener.Stop()
    $listener.Close()
    Write-Host "Mock server stopped." -ForegroundColor Yellow
}