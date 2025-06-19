#!/usr/bin/env pwsh
# Script to clean up the old repository

# Function for logging
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path "cleanup.log" -Value $logMessage
    
    # Also output to console with color
    $color = switch ($Level) {
        "INFO" { "White" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        "SUCCESS" { "Green" }
        default { "White" }
    }
    
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $color
    Write-Output $logMessage
    $host.UI.RawUI.ForegroundColor = $fc
}

# Start logging
Write-Log -Message "Starting repository cleanup process" -Level "INFO"

# Get GitHub username automatically from GitHub CLI
try {
    Write-Log -Message "Getting GitHub username from GitHub CLI" -Level "INFO"
    $userJson = gh api user | ConvertFrom-Json
    $GithubUsername = $userJson.login
    
    if (-not $GithubUsername) {
        Write-Log -Message "Failed to get GitHub username from CLI" -Level "ERROR"
        exit 1
    }
    
    Write-Log -Message "GitHub username detected: $GithubUsername" -Level "SUCCESS"
}
catch {
    Write-Log -Message "Error getting GitHub username: $_" -Level "ERROR"
    exit 1
}

# Confirm before deleting
Write-Log -Message "Preparing to delete repository: $GithubUsername/elmentor-landing-page-clean" -Level "WARNING"
$confirmation = Read-Host "Do you want to delete the repository $GithubUsername/elmentor-landing-page-clean? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Log -Message "Operation cancelled by user" -Level "INFO"
    exit 0
}

# Delete repository
Write-Log -Message "Deleting repository: $GithubUsername/elmentor-landing-page-clean" -Level "WARNING"
gh repo delete "$GithubUsername/elmentor-landing-page-clean" --yes

if ($LASTEXITCODE -eq 0) {
    Write-Log -Message "Repository successfully deleted" -Level "SUCCESS"
} else {
    Write-Log -Message "Error deleting repository" -Level "ERROR"
    exit 1
}

# Final confirmation
Write-Log -Message "Cleanup completed. The old repository has been deleted." -Level "SUCCESS"
Write-Log -Message "Active repository: $GithubUsername/$GithubUsername-landing-page-clean" -Level "INFO"
Write-Log -Message "Site URL: https://$GithubUsername.github.io/$GithubUsername-landing-page-clean/" -Level "INFO"
