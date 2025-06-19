#!/usr/bin/env pwsh
# Script to update all GitHub username references in the project

# Function to display colored messages
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    else {
        $input | Write-Output
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Function to update GitHub username in a file
function Update-GitHubUsername {
    param(
        [string]$FilePath,
        [string]$OldUsername,
        [string]$NewUsername
    )
    
    if (Test-Path $FilePath) {
        $content = Get-Content -Path $FilePath -Raw
        if ($content -match $OldUsername) {
            $updatedContent = $content.Replace($OldUsername, $NewUsername)
            Set-Content -Path $FilePath -Value $updatedContent -NoNewline
            Write-ColorOutput Green "Updated username in $FilePath"
            return $true
        } else {
            Write-ColorOutput Yellow "No username references found in $FilePath"
            return $false
        }
    } else {
        Write-ColorOutput Red "File not found: $FilePath"
        return $false
    }
}

Write-ColorOutput Cyan @"
===========================================================
   GitHub Username Update Utility
===========================================================
"@

# Get the current username from deploy-github-pages.ps1
$deployScriptPath = "$PSScriptRoot\deploy-github-pages.ps1"
$currentUsername = "aymanaboghonim"  # Default value
if (Test-Path $deployScriptPath) {
    $deployScript = Get-Content -Path $deployScriptPath -Raw
    if ($deployScript -match 'git@github\.com:([^/]+)/') {
        $currentUsername = $Matches[1]
        Write-ColorOutput Yellow "Current GitHub username found: $currentUsername"
    }
}

# Prompt for GitHub username
$githubUsername = Read-Host "Enter your GitHub username"

if ([string]::IsNullOrWhiteSpace($githubUsername)) {
    Write-ColorOutput Red "Username cannot be empty. Exiting."
    exit 1
}

Write-ColorOutput Cyan "Updating username from '$currentUsername' to '$githubUsername' in all project files..."

# List of files to update
$filesToUpdate = @(
    "$PSScriptRoot\deploy-github-pages.ps1",
    "$PSScriptRoot\auto-deploy-silent.ps1",
    "$PSScriptRoot\README.md",
    "$PSScriptRoot\GITHUB_PAGES_DEPLOYMENT.md",
    "$PSScriptRoot\NEXT_STEPS.md",
    "$PSScriptRoot\AUTOMATED_DEPLOYMENT_OPTIONS.md",
    "$PSScriptRoot\auto-deploy-silent.bat"
)

$updatedCount = 0
foreach ($file in $filesToUpdate) {
    if (Update-GitHubUsername -FilePath $file -OldUsername $currentUsername -NewUsername $githubUsername) {
        $updatedCount++
    }
}

# Also search and update URLs in any other file
$allFiles = Get-ChildItem -Path $PSScriptRoot -File -Recurse -Include "*.md", "*.ps1", "*.bat", "*.ts", "*.tsx", "*.js", "*.json" |
            Where-Object { $_.FullName -notin $filesToUpdate }

foreach ($file in $allFiles) {
    $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -match $currentUsername) {
        $updatedContent = $content.Replace($currentUsername, $githubUsername)
        Set-Content -Path $file.FullName -Value $updatedContent -NoNewline
        Write-ColorOutput Green "Updated username in $($file.FullName)"
        $updatedCount++
    }
}

Write-ColorOutput Green "Username update completed. Updated $updatedCount files."
Write-ColorOutput Cyan "Your GitHub username has been updated to: $githubUsername"
Write-ColorOutput Cyan @"
===========================================================
   Next Steps
===========================================================
1. To deploy to GitHub Pages, run:
   npm run deploy
   
   Or use the batch file:
   .\deploy-github-pages.bat

2. After deployment, the site will be available at:
   https://$githubUsername.github.io/elmentor-landing-page-clean/
===========================================================
"@
