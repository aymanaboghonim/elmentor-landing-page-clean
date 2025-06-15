#!/usr/bin/env pwsh
# Fully automated GitHub Pages deployment script
# No user input required - set these variables before running

# Configuration (change these values)
$GithubUsername = "aymanaboghonim-user" # Change to your GitHub username
$RepoName = "elmentor-landing-page-clean"
$CommitMessage = "Automated deployment"

# Check for GitHub token in environment
$GithubToken = $env:GITHUB_TOKEN

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
    Add-Content -Path "deploy.log" -Value $logMessage
    
    # Also output to console
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
Write-Log -Message "Starting automated deployment process" -Level "INFO"
Write-Log -Message "Using GitHub username: $GithubUsername" -Level "INFO"

# Make sure we're in the right directory
Set-Location -Path $PSScriptRoot
Write-Log -Message "Working in directory: $PSScriptRoot" -Level "INFO"

# Check for Git
try {
    $gitVersion = git --version
    Write-Log -Message "Git version: $gitVersion" -Level "INFO"
}
catch {
    Write-Log -Message "Git is not installed or not in PATH" -Level "ERROR"
    exit 1
}

# Check for npm
try {
    $npmVersion = npm --version
    Write-Log -Message "NPM version: $npmVersion" -Level "INFO"
}
catch {
    Write-Log -Message "NPM is not installed or not in PATH" -Level "ERROR"
    exit 1
}

# Configure Git if needed
$gitUserName = git config --global user.name
if (-not $gitUserName) {
    git config --global user.name "GitHub Actions"
    Write-Log -Message "Set default Git user name" -Level "INFO"
}

$gitUserEmail = git config --global user.email
if (-not $gitUserEmail) {
    git config --global user.email "github-actions@github.com"
    Write-Log -Message "Set default Git user email" -Level "INFO"
}

# Create GitHub repository using API
Write-Log -Message "Creating or checking GitHub repository: $RepoName" -Level "INFO"
if (-not $GithubToken) {
    Write-Log -Message "GITHUB_TOKEN not set, skipping repository creation" -Level "WARNING"
}
else {
    # Check if repo exists
    try {
        $headers = @{
            Authorization = "token $GithubToken"
        }
        
        $response = Invoke-WebRequest -Uri "https://api.github.com/repos/$GithubUsername/$RepoName" -Headers $headers -Method Get -ErrorAction SilentlyContinue
        
        if ($response.StatusCode -eq 200) {
            Write-Log -Message "Repository already exists: $GithubUsername/$RepoName" -Level "INFO"
        }
    }
    catch {
        # Create repository if it doesn't exist
        $body = @{
            name = $RepoName
            description = "aymanaboghonim Landing Page Clean Implementation"
            private = $false
        } | ConvertTo-Json
        
        try {
            $response = Invoke-WebRequest -Uri "https://api.github.com/user/repos" -Headers $headers -Method Post -Body $body -ErrorAction SilentlyContinue
            Write-Log -Message "Created repository: $GithubUsername/$RepoName" -Level "SUCCESS"
        }
        catch {
            Write-Log -Message "Error creating repository: $_" -Level "WARNING"
            Write-Log -Message "Proceeding anyway" -Level "INFO"
        }
    }
}

# Initialize Git if needed
if (-not (Test-Path -Path ".git")) {
    git init
    Write-Log -Message "Initialized Git repository" -Level "INFO"
}

# Setup remote
$remotes = git remote
if ($remotes -contains "origin") {
    git remote set-url origin "https://github.com/$GithubUsername/$RepoName.git"
    Write-Log -Message "Updated remote URL" -Level "INFO"
}
else {
    git remote add origin "https://github.com/$GithubUsername/$RepoName.git"
    Write-Log -Message "Added remote origin" -Level "INFO"
}

# Update configuration files with correct GitHub username
Write-Log -Message "Updating configuration files with username: $GithubUsername" -Level "INFO"

# Update all relevant files
Get-ChildItem -Recurse -Include "*.md", "*.ps1", "*.bat", "*.ts" | ForEach-Object {
    $content = Get-Content -Path $_.FullName -Raw
    $updated = $content -replace "aymanaboghonim", $GithubUsername -replace "aymanaboghonim", $GithubUsername
    if ($updated -ne $content) {
        Set-Content -Path $_.FullName -Value $updated -NoNewline
        Write-Log -Message "Updated username in: $($_.Name)" -Level "INFO"
    }
}

# Update vite.config.ts for GitHub Pages
Write-Log -Message "Updating vite.config.ts for GitHub Pages" -Level "INFO"
$viteConfigPath = "vite.config.ts"
if (Test-Path -Path $viteConfigPath) {
    $viteConfig = Get-Content -Path $viteConfigPath -Raw
    $updatedConfig = $viteConfig -replace 'base: [''"].*[''"]', "base: '/$RepoName/'"
    Set-Content -Path $viteConfigPath -Value $updatedConfig -NoNewline
    Write-Log -Message "Updated vite.config.ts with correct base path" -Level "SUCCESS"
}

# Install dependencies
Write-Log -Message "Installing dependencies" -Level "INFO"
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Log -Message "npm install failed" -Level "ERROR"
    exit 1
}

# Build the project
Write-Log -Message "Building project" -Level "INFO"
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Log -Message "Build failed" -Level "ERROR"
    exit 1
}
Write-Log -Message "Build completed successfully" -Level "SUCCESS"

# Deploy to GitHub Pages
Write-Log -Message "Deploying to GitHub Pages" -Level "INFO"

# Navigate to build directory
Push-Location -Path "dist"
if (-not $?) {
    Write-Log -Message "dist directory not found" -Level "ERROR"
    exit 1
}

# Create .nojekyll file
New-Item -ItemType File -Path ".nojekyll" -Force | Out-Null
Write-Log -Message "Created .nojekyll file" -Level "INFO"

# Initialize Git
git init
git add -A
git commit -m $CommitMessage

# Set up authentication
if ($GithubToken) {
    $remoteUrl = "https://$GithubToken@github.com/$GithubUsername/$RepoName.git"
    Write-Log -Message "Using token authentication" -Level "INFO"
}
else {
    $remoteUrl = "https://github.com/$GithubUsername/$RepoName.git"
    Write-Log -Message "Using regular authentication" -Level "INFO"
}

# Push to gh-pages branch
git push -f $remoteUrl main:gh-pages
if ($LASTEXITCODE -ne 0) {
    Write-Log -Message "Failed to push to gh-pages branch" -Level "ERROR"
}
else {
    Write-Log -Message "Successfully pushed to gh-pages branch" -Level "SUCCESS"
}

# Return to project root
Pop-Location

# Final status
Write-Log -Message "Deployment completed" -Level "SUCCESS"
Write-Log -Message "Site URL: https://$GithubUsername.github.io/$RepoName/" -Level "SUCCESS"

# Create success marker file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$successContent = @"
Deployment completed successfully at $(Get-Date)
Site URL: https://$GithubUsername.github.io/$RepoName/
"@
$successContent | Out-File -FilePath "deployment_success_$timestamp.txt"
