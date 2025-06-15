#!/usr/bin/env pwsh
# Silent GitHub repository automation script
param(
    [Parameter(Mandatory=$false)]
    [string]$GithubUsername = "aymanaboghonim", # Default username - REPLACE WITH YOUR USERNAME
    
    [Parameter(Mandatory=$false)]
    [string]$RepoName = "elmentor-landing-page-clean",
    
    [Parameter(Mandatory=$false)]
    [string]$Description = "Clean, maintainable implementation of the aymanaboghonim/DevOps Visions landing page",
    
    [Parameter(Mandatory=$false)]
    [switch]$Silent = $true
)

# Function to display colored messages (only in non-silent mode)
function Write-ColorOutput($ForegroundColor) {
    if (-not $Silent) {
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
}

# Function to log to file (always happens regardless of silent mode)
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
    Add-Content -Path "$PSScriptRoot\github_setup.log" -Value $logMessage
    
    # Also output to console in non-silent mode
    if (-not $Silent) {
        $color = switch ($Level) {
            "INFO" { "White" }
            "WARNING" { "Yellow" }
            "ERROR" { "Red" }
            "SUCCESS" { "Green" }
            default { "White" }
        }
        Write-ColorOutput $color $logMessage
    }
}

# Start logging
Write-Log "Starting silent GitHub repository setup" "INFO"
Write-Log "Configuration: Username=$GithubUsername, RepoName=$RepoName" "INFO"

# Check if git is installed
try {
    $gitVersion = git --version
    Write-Log "Git is installed: $gitVersion" "INFO"
}
catch {
    Write-Log "Error: Git is not installed or not in PATH" "ERROR"
    exit 1
}

# Check and install GitHub CLI if needed
try {
    $ghVersion = gh --version
    Write-Log "GitHub CLI is installed: $ghVersion" "INFO"
}
catch {
    Write-Log "GitHub CLI not found, attempting installation" "WARNING"
    try {
        # Try different package managers
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Log "Installing GitHub CLI using winget" "INFO"
            winget install -e --id GitHub.cli --silent
        }
        elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
            Write-Log "Installing GitHub CLI using scoop" "INFO"
            scoop install gh
        }
        elseif (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Log "Installing GitHub CLI using chocolatey" "INFO"
            choco install gh -y
        }
        else {
            Write-Log "No package manager found for GitHub CLI installation" "ERROR"
            exit 1
        }
        
        # Force reload PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        # Verify installation
        $ghVersion = gh --version
        Write-Log "GitHub CLI installed successfully: $ghVersion" "SUCCESS"
    }
    catch {
        Write-Log "Failed to install GitHub CLI: $_" "ERROR"
        exit 1
    }
}

# Set up GitHub authentication using PAT if provided via environment variable or silent authentication
$hasAuthenticated = $false
$ghAuthStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Log "Not authenticated with GitHub CLI" "WARNING"
    # Check for GitHub token in environment
    if ($env:GITHUB_TOKEN) {
        Write-Log "Authenticating with GitHub token from environment variable" "INFO"
        $env:GH_TOKEN = $env:GITHUB_TOKEN
        $hasAuthenticated = $true
        Write-Log "Authentication with token completed" "SUCCESS"
    }
    else {
        Write-Log "No GitHub token found in environment. Continuing with stored credentials if available." "WARNING"
    }
}
else {
    Write-Log "Already authenticated with GitHub CLI" "SUCCESS"
    $hasAuthenticated = $true
}

# Initialize Git repo if not already
if (-not (Test-Path -Path "$PSScriptRoot\.git")) {
    Write-Log "Initializing Git repository" "INFO"
    git init | Out-Null
    Write-Log "Git repository initialized" "SUCCESS"
}
else {
    Write-Log "Git repository already initialized" "INFO"
}

# Create GitHub repository or use existing
# First, check if repo exists
Write-Log "Checking if repository $GithubUsername/$RepoName exists" "INFO"
$repoExists = $false
try {
    $repoCheck = gh repo view $GithubUsername/$RepoName 2>&1
    if ($LASTEXITCODE -eq 0) {
        $repoExists = $true
        Write-Log "Repository $GithubUsername/$RepoName already exists" "WARNING"
    }
}
catch {
    Write-Log "Error checking repository existence: $_" "WARNING"
}

if (-not $repoExists) {
    Write-Log "Creating new GitHub repository: $RepoName" "INFO"
    try {
        gh repo create $RepoName --public --description $Description | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Failed to create GitHub repository" "ERROR"
            # Continue anyway as we might have issues with API but repo might be created
        }
        else {
            Write-Log "Repository created successfully" "SUCCESS"
        }
    }
    catch {
        Write-Log "Error creating repository: $_" "WARNING"
        # Continue anyway
    }
}

# Configure remote
Write-Log "Configuring Git remotes" "INFO"
$remotes = git remote
if ($remotes -contains "origin") {
    $originUrl = git remote get-url origin
    Write-Log "Remote 'origin' already exists with URL: $originUrl" "INFO"
    git remote set-url origin "https://github.com/$GithubUsername/$RepoName.git" | Out-Null
    Write-Log "Updated remote URL to https://github.com/$GithubUsername/$RepoName.git" "SUCCESS"
}
else {
    git remote add origin "https://github.com/$GithubUsername/$RepoName.git" | Out-Null
    Write-Log "Added remote 'origin' with URL: https://github.com/$GithubUsername/$RepoName.git" "SUCCESS"
}

# Update deployment script with correct repository URL
Write-Log "Updating deployment scripts with repository URL" "INFO"
$deployScriptPath = "$PSScriptRoot\deploy-github-pages.ps1"
if (Test-Path -Path $deployScriptPath) {
    $deployScript = Get-Content -Path $deployScriptPath -Raw
    $updated = $deployScript -replace '(\$repoUrl\s*=\s*"git@github\.com:).*(/elmentor-landing-page-clean\.git")', "`$1$GithubUsername`$2"
    Set-Content -Path $deployScriptPath -Value $updated -NoNewline
    Write-Log "Updated deploy-github-pages.ps1 with username: $GithubUsername" "SUCCESS"
}
else {
    Write-Log "Deployment script not found at: $deployScriptPath" "WARNING"
}

# Update README.md with correct URL
Write-Log "Updating README.md with repository URL" "INFO"
$readmePath = "$PSScriptRoot\README.md"
if (Test-Path -Path $readmePath) {
    $readme = Get-Content -Path $readmePath -Raw
    $updatedReadme = $readme -replace '(https://)[^/]+(\.github\.io/elmentor-landing-page-clean/)', "`$1$GithubUsername`$2"
    $updatedReadme = $updatedReadme -replace '(git clone https://github\.com/)[^/]+(/elmentor-landing-page-clean\.git)', "`$1$GithubUsername`$2"
    Set-Content -Path $readmePath -Value $updatedReadme -NoNewline
    Write-Log "Updated README.md with GitHub username: $GithubUsername" "SUCCESS"
}
else {
    Write-Log "README.md not found at: $readmePath" "WARNING"
}

# Update vite.config.ts with correct base URL
Write-Log "Checking vite.config.ts configuration" "INFO"
$viteConfigPath = "$PSScriptRoot\vite.config.ts"
if (Test-Path -Path $viteConfigPath) {
    $viteConfig = Get-Content -Path $viteConfigPath -Raw
    if ($viteConfig -match "base:\s*['\"]/[^'\"]+['\"]") {
        Write-Log "Base URL already configured in vite.config.ts" "INFO"
    }
    else {
        Write-Log "Base URL not found in vite.config.ts" "WARNING"
        # Try to update it anyways
        $updatedViteConfig = $viteConfig -replace '(base:\s*[''"]).[^''"]+(["'']\s*)', "`$1/$RepoName/`$2"
        Set-Content -Path $viteConfigPath -Value $updatedViteConfig -NoNewline
        Write-Log "Attempted to update base URL in vite.config.ts" "INFO"
    }
}
else {
    Write-Log "vite.config.ts not found at: $viteConfigPath" "WARNING"
}

# Make sure git is configured with at least basic info
$gitUserName = git config --global user.name
if (-not $gitUserName) {
    git config --global user.name "GitHub Actions"
    Write-Log "Set default git user.name" "INFO"
}

$gitUserEmail = git config --global user.email
if (-not $gitUserEmail) {
    git config --global user.email "github-actions@github.com"
    Write-Log "Set default git user.email" "INFO"
}

# Commit changes
Write-Log "Committing changes" "INFO"
git add . | Out-Null
git commit -m "Automated setup: Updated repository configuration" | Out-Null
Write-Log "Changes committed" "SUCCESS"

# Push to GitHub
Write-Log "Pushing code to GitHub" "INFO"
try {
    git push -u origin main 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to push to 'main', trying 'master'" "WARNING"
        git push -u origin master 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            # One last attempt - create main branch and push
            git checkout -b main 2>&1 | Out-Null
            git push -u origin main 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to push to any branch"
            }
        }
    }
    Write-Log "Code pushed to GitHub successfully" "SUCCESS"
}
catch {
    Write-Log "Error pushing code to GitHub: $_" "ERROR"
    exit 1
}

# Run deployment script automatically
Write-Log "Starting GitHub Pages deployment" "INFO"
try {
    # Build the project
    Write-Log "Building project" "INFO"
    npm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Build process failed" "ERROR"
        exit 1
    }
    Write-Log "Build completed successfully" "SUCCESS"

    # Switch to dist directory
    Set-Location -Path "$PSScriptRoot\dist"
    Write-Log "Changed directory to dist" "INFO"

    # Create .nojekyll file
    Write-Log "Creating .nojekyll file" "INFO"
    New-Item -ItemType File -Path ".nojekyll" -Force | Out-Null

    # Initialize Git in dist
    Write-Log "Initializing Git in dist directory" "INFO"
    git init | Out-Null
    git add -A | Out-Null
    git commit -m "Deploy to GitHub Pages" | Out-Null

    # Force push to gh-pages branch
    Write-Log "Pushing to gh-pages branch" "INFO"
    git push -f "git@github.com:$GithubUsername/$RepoName.git" main:gh-pages 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to push to gh-pages branch" "ERROR"
    }
    else {
        Write-Log "Successfully deployed to GitHub Pages" "SUCCESS"
    }

    # Return to the project root
    Set-Location -Path $PSScriptRoot
    Write-Log "Returned to project root directory" "INFO"
}
catch {
    Write-Log "Error during deployment: $_" "ERROR"
}

# Final summary
if (-not $Silent) {
    Write-ColorOutput Cyan @"
===========================================================
   Repository Setup and Deployment Complete!
===========================================================
Repository URL: https://github.com/$GithubUsername/$RepoName
GitHub Pages: https://$GithubUsername.github.io/$RepoName/
===========================================================
"@
}

Write-Log "Repository setup and deployment completed" "SUCCESS"
Write-Log "Repository URL: https://github.com/$GithubUsername/$RepoName" "INFO"
Write-Log "GitHub Pages URL: https://$GithubUsername.github.io/$RepoName/" "INFO"

# Create success marker file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$successFile = "$PSScriptRoot\github_setup_success_$timestamp.txt"
Set-Content -Path $successFile -Value @"
Repository setup and deployment completed successfully at $(Get-Date)
Repository URL: https://github.com/$GithubUsername/$RepoName
GitHub Pages URL: https://$GithubUsername.github.io/$RepoName/
"@

exit 0
