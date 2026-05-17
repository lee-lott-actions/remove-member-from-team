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
        $env:GITHUB_OUTPUT = New-TemporaryFile
        $env:MOCK_API = $script:MockApiUrl
    }
	
    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Item Env:MOCK_API -ErrorAction SilentlyContinue
    }

	Context "Success Cases" {
	    It "unit: Remove-MemberFromTeam succeeds with HTTP 204" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 204; Content = '' }
	        }
	        Remove-MemberFromTeam -MemberName $MemberName -TeamName $TeamName -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=success"
	    }
	}

	Context "HTTP Failure Cases" {
	    It "unit: Remove-MemberFromTeam fails with HTTP 404" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 404; Content = '{"message":"Not Found"}' }
	        }
	        Remove-MemberFromTeam -MemberName $MemberName -TeamName $TeamName -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Error: Failed to remove $MemberName from team $TeamName. HTTP Status: 404"
	    }
	}

	Context "Parameter Validation Failure Cases" {
		It "unit: Remove-MemberFromTeam fails with empty MemberName" {
	        Remove-MemberFromTeam -MemberName "" -TeamName $TeamName -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided."
	    }
	
	    It "unit: Remove-MemberFromTeam fails with empty TeamName" {
	        Remove-MemberFromTeam -MemberName $MemberName -TeamName "" -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided."
	    }
	
	    It "unit: Remove-MemberFromTeam fails with empty Token" {
	        Remove-MemberFromTeam -MemberName $MemberName -TeamName $TeamName -Token "" -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided."
	    }
	
	    It "unit: Remove-MemberFromTeam fails with empty Owner" {
	        Remove-MemberFromTeam -MemberName $MemberName -TeamName $TeamName -Token $Token -Owner ""
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: member-name, team-name, token, and owner must be provided."
	    }
	}

	Context "Exception Failure Cases" {
		It "unit: Remove-MemberFromTeam  fails with exception" {
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
}
