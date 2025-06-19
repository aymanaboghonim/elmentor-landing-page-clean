#!/usr/bin/env pwsh
# Script to create a new GitHub repository and push the local code
param(
    [Parameter(Mandatory=$true)]
    [string]$GithubUsername,
    
    [Parameter(Mandatory=$false)]
    [string]$RepoName = "elmentor-landing-page-clean",
    
    [Parameter(Mandatory=$false)]
    [string]$Description = "Clean, maintainable implementation of the aymanaboghonim/DevOps Visions landing page"
)

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

# Validate GitHub username
if ([string]::IsNullOrWhiteSpace($GithubUsername)) {
    Write-ColorOutput Red "Error: GitHub username cannot be empty."
    exit 1
}

# Display script banner
Write-ColorOutput Cyan @"
===========================================================
   GitHub Repository Creation and Code Push Automation
===========================================================
"@

# Display parameters
Write-ColorOutput Yellow "GitHub Username: $GithubUsername"
Write-ColorOutput Yellow "Repository Name: $RepoName"
Write-ColorOutput Yellow "Repository Description: $Description"
Write-ColorOutput Yellow "Local Directory: $PSScriptRoot"
Write-Host ""

# Check if git is installed
Write-ColorOutput Cyan "Checking if Git is installed..."
try {
    $gitVersion = git --version
    Write-ColorOutput Green "Git is installed: $gitVersion"
}
catch {
    Write-ColorOutput Red "Error: Git is not installed or not in PATH. Please install Git and try again."
    exit 1
}

# Check if gh CLI is installed
Write-ColorOutput Cyan "Checking if GitHub CLI is installed..."
try {
    $ghVersion = gh --version
    Write-ColorOutput Green "GitHub CLI is installed: $ghVersion"
}
catch {
    Write-ColorOutput Red "GitHub CLI (gh) is not installed."
    $installGh = Read-Host "Would you like to install GitHub CLI now? (y/n)"
    if ($installGh -eq "y") {
        Write-ColorOutput Yellow "Installing GitHub CLI..."
        try {
            # Check if winget is available
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                winget install -e --id GitHub.cli
            }
            # Check if scoop is available
            elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
                scoop install gh
            }
            # Check if chocolatey is available
            elseif (Get-Command choco -ErrorAction SilentlyContinue) {
                choco install gh
            }
            else {
                Write-ColorOutput Red "No package manager (winget, scoop, chocolatey) found."
                Write-ColorOutput Yellow "Please install GitHub CLI manually from: https://cli.github.com/"
                exit 1
            }
            
            # Verify installation
            $ghVersion = gh --version
            Write-ColorOutput Green "GitHub CLI installed successfully: $ghVersion"
        }
        catch {
            Write-ColorOutput Red "Failed to install GitHub CLI. Please install it manually from: https://cli.github.com/"
            exit 1
        }
    }
    else {
        Write-ColorOutput Red "GitHub CLI is required for this script. Please install it from: https://cli.github.com/"
        exit 1
    }
}

# Check if user is logged into GitHub CLI
Write-ColorOutput Cyan "Checking GitHub CLI authentication..."
$ghAuthStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput Yellow "Not authenticated with GitHub CLI. Initiating login..."
    gh auth login
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput Red "Failed to authenticate with GitHub CLI."
        exit 1
    }
}
else {
    Write-ColorOutput Green "Already authenticated with GitHub CLI."
}

# Initialize Git repo if not already
Write-ColorOutput Cyan "Initializing Git repository..."
if (-not (Test-Path -Path "$PSScriptRoot\.git")) {
    git init
    Write-ColorOutput Green "Git repository initialized."
}
else {
    Write-ColorOutput Green "Git repository already initialized."
}

# Check if repo already exists
Write-ColorOutput Cyan "Checking if repository already exists on GitHub..."
$repoExists = gh repo view $GithubUsername/$RepoName 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput Yellow "Repository $GithubUsername/$RepoName already exists on GitHub."
    $continueAnyway = Read-Host "Do you want to use this existing repository? (y/n)"
    if ($continueAnyway -ne "y") {
        Write-ColorOutput Yellow "Operation cancelled by user."
        exit 0
    }
}
else {
    # Create GitHub repository
    Write-ColorOutput Cyan "Creating new GitHub repository: $RepoName..."
    gh repo create $RepoName --public --description $Description
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput Red "Failed to create GitHub repository."
        exit 1
    }
    Write-ColorOutput Green "Repository created successfully."
}

# Configure remote if not already set
Write-ColorOutput Cyan "Configuring Git remotes..."
$remotes = git remote
if ($remotes -contains "origin") {
    $originUrl = git remote get-url origin
    Write-ColorOutput Yellow "Remote 'origin' already exists with URL: $originUrl"
    $updateRemote = Read-Host "Do you want to update the remote URL? (y/n)"
    if ($updateRemote -eq "y") {
        git remote set-url origin "https://github.com/$GithubUsername/$RepoName.git"
        Write-ColorOutput Green "Remote URL updated."
    }
}
else {
    git remote add origin "https://github.com/$GithubUsername/$RepoName.git"
    Write-ColorOutput Green "Remote 'origin' added."
}

# Update the deployment script with correct repository URL
Write-ColorOutput Cyan "Updating deployment script with repository URL..."
$deployScriptPath = "$PSScriptRoot\deploy-github-pages.ps1"
if (Test-Path -Path $deployScriptPath) {
    $deployScript = Get-Content -Path $deployScriptPath -Raw
    $updated = $deployScript -replace '(\$repoUrl\s*=\s*"git@github\.com:).*(/elmentor-landing-page-clean\.git")', "`$1$GithubUsername`$2"
    Set-Content -Path $deployScriptPath -Value $updated
    Write-ColorOutput Green "Deployment script updated with GitHub username: $GithubUsername"
}
else {
    Write-ColorOutput Yellow "Deployment script not found at: $deployScriptPath"
}

# Update README.md with correct URL
Write-ColorOutput Cyan "Updating README.md with repository URL..."
$readmePath = "$PSScriptRoot\README.md"
if (Test-Path -Path $readmePath) {
    $readme = Get-Content -Path $readmePath -Raw
    $updatedReadme = $readme -replace '(https://)[^/]+(\.github\.io/elmentor-landing-page-clean/)', "`$1$GithubUsername`$2"
    $updatedReadme = $updatedReadme -replace '(git clone https://github\.com/)[^/]+(/elmentor-landing-page-clean\.git)', "`$1$GithubUsername`$2"
    Set-Content -Path $readmePath -Value $updatedReadme
    Write-ColorOutput Green "README.md updated with GitHub username: $GithubUsername"
}
else {
    Write-ColorOutput Yellow "README.md not found at: $readmePath"
}

# Update vite.config.ts with correct base URL
Write-ColorOutput Cyan "Ensuring vite.config.ts has correct base URL..."
$viteConfigPath = "$PSScriptRoot\vite.config.ts"
if (Test-Path -Path $viteConfigPath) {
    $viteConfig = Get-Content -Path $viteConfigPath -Raw
    if ($viteConfig -match "base:\s*['\"]/.+['\"]") {
        Write-ColorOutput Green "Base URL already configured in vite.config.ts"
    }
    else {
        Write-ColorOutput Yellow "Base URL not found in vite.config.ts. Please check configuration manually."
    }
}
else {
    Write-ColorOutput Yellow "vite.config.ts not found at: $viteConfigPath"
}

# Commit changes
Write-ColorOutput Cyan "Committing changes..."
git add .
git commit -m "Initial commit with automated setup"

# Push to GitHub
Write-ColorOutput Cyan "Pushing code to GitHub..."
git push -u origin main
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput Yellow "Failed to push to 'main'. Trying 'master' branch..."
    git push -u origin master
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput Red "Failed to push to GitHub. Please check your credentials and try manually."
        exit 1
    }
}

Write-ColorOutput Green "Code pushed to GitHub successfully!"

# Display deployment instructions
Write-ColorOutput Cyan @"
===========================================================
   Repository Setup Complete! Next Steps:
===========================================================
1. To deploy to GitHub Pages, run:
   npm run deploy
   
   Or use the batch file:
   .\deploy-github-pages.bat

2. After deployment, the site will be available at:
   https://$GithubUsername.github.io/elmentor-landing-page-clean/

3. Follow POST_DEPLOYMENT_CHECKLIST.md to verify your deployment.
===========================================================
"@
