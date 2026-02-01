Describe "Remove-MemberFromTeam" {
    BeforeAll {
        $script:MemberName = "test-user"
        $script:TeamName   = "test-team"
        $script:Token      = "fake-token"
        $script:Owner      = "test-owner"
        $script:MockApiUrl = "http://127.0.0.1:3000"
        . "$PSScriptRoot/../action.ps1"
    }
    BeforeEach {
        $env:GITHUB_OUTPUT = "$PSScriptRoot/github_output.temp"
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        $env:MOCK_API = $script:MockApiUrl
    }
    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Variable -Name MOCK_API -Scope Global -ErrorAction SilentlyContinue
    }

    It "succeeds with HTTP 204" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{ StatusCode = 204; Content = '' }
        }
        Remove-MemberFromTeam -MemberName $MemberName -TeamName $TeamName -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=success"
    }

    It "fails with HTTP 404 (team or user not found)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{ StatusCode = 404; Content = '{"message":"Not Found"}' }
        }
        Remove-MemberFromTeam -MemberName $MemberName -TeamName $TeamName -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Failed to remove member test-user from team test-team. HTTP Status: 404"
    }

    It "fails with empty member_name" {
        Remove-MemberFromTeam -MemberName "" -TeamName $TeamName -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided."
    }

    It "fails with empty team_name" {
        Remove-MemberFromTeam -MemberName $MemberName -TeamName "" -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided."
    }

    It "fails with empty token" {
        Remove-MemberFromTeam -MemberName $MemberName -TeamName $TeamName -Token "" -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided."
    }

    It "fails with empty owner" {
        Remove-MemberFromTeam -MemberName $MemberName -TeamName $TeamName -Token $Token -Owner ""
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided."
    }
	
	It "writes result=failure and error-message on exception" {
	Mock Invoke-WebRequest { throw "API Error" }

	try {
		Remove-MemberFromTeam -MemberName $MemberName -TeamName $TeamName -Token $Token -Owner $Owner
	} catch {}

	$output = Get-Content $env:GITHUB_OUTPUT
	$output | Should -Contain "result=failure"
	$output | Where-Object { $_ -match "^error-message=Error: Failed to remove $MemberName from team $TeamName\. Exception:" } |
		Should -Not -BeNullOrEmpty
	}
}