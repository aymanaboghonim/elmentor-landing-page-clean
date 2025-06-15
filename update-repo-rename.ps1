#!/usr/bin/env pwsh
# Script to update all files with the new repository name

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
    Add-Content -Path "rename-update.log" -Value $logMessage
    
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
Write-Log -Message "Starting project files update for repository rename" -Level "INFO"

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
    $oldRepoName = "$GithubUsername-landing-page-clean"
    $newRepoName = "elmentor-landing-page-clean"
    
    Write-Log -Message "Old repository name: $oldRepoName" -Level "INFO"
    Write-Log -Message "New repository name: $newRepoName" -Level "INFO"
}
catch {
    Write-Log -Message "Error getting GitHub username: $_" -Level "ERROR"
    exit 1
}

# Make sure we're in the right directory
$repoPath = (Get-Location).Path
Write-Log -Message "Working in directory: $repoPath" -Level "INFO"

# Update all relevant files
Write-Log -Message "Updating all files with the new repository name" -Level "INFO"
Get-ChildItem -Recurse -Include "*.md", "*.ps1", "*.bat", "*.ts", "*.js", "*.tsx", "*.jsx", "*.html", "*.css" | ForEach-Object {
    $content = Get-Content -Path $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($content) {
        $updated = $content -replace $oldRepoName, $newRepoName
        if ($updated -ne $content) {
            try {
                Set-Content -Path $_.FullName -Value $updated -NoNewline -ErrorAction Stop
                Write-Log -Message "Updated repository name in: $($_.Name)" -Level "SUCCESS"
            }
            catch {
                Write-Log -Message "Error updating file $($_.Name): $_" -Level "ERROR"
            }
        }
    }
}

# Update vite.config.ts specifically
Write-Log -Message "Updating vite.config.ts for GitHub Pages" -Level "INFO"
$viteConfigPath = "vite.config.ts"
if (Test-Path -Path $viteConfigPath) {
    $viteConfig = Get-Content -Path $viteConfigPath -Raw
    $updatedConfig = $viteConfig -replace 'base:\s*["].*["]', "base: `"/$newRepoName/`""
    Set-Content -Path $viteConfigPath -Value $updatedConfig -NoNewline
    Write-Log -Message "Updated vite.config.ts with correct base path" -Level "SUCCESS"
}

# Final confirmation
Write-Log -Message "Update completed. Files now reference the new repository: $newRepoName" -Level "SUCCESS"
Write-Log -Message "New repository URL: https://github.com/$GithubUsername/$newRepoName" -Level "INFO"
Write-Log -Message "New GitHub Pages URL: https://$GithubUsername.github.io/$newRepoName/" -Level "INFO"
Write-Log -Message "To deploy to the renamed repository, run the deployment script" -Level "INFO"
