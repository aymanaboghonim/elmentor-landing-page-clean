#!/usr/bin/env pwsh
# Enhanced GitHub Pages deployment with Git "dubious ownership" fix

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

# Repository name - will be updated with actual username later
$RepoName = "elmentor-landing-page-clean"
$CommitMessage = "Automated deployment"

# Start logging
Write-Log -Message "Starting automated deployment process" -Level "INFO"

# Fix Git "dubious ownership" issues
Write-Log -Message "Checking for Git ownership issues" -Level "INFO"
$repoPath = (Get-Location).Path
$distPath = Join-Path -Path $repoPath -ChildPath "dist"

# Add both the repository and dist directory to Git safe.directory
git config --global --add safe.directory $repoPath
Write-Log -Message "Repository path added to safe.directory: $repoPath" -Level "SUCCESS"

if (Test-Path -Path $distPath) {
    git config --global --add safe.directory $distPath
    Write-Log -Message "Dist path added to safe.directory: $distPath" -Level "SUCCESS"
} else {
    Write-Log -Message "Dist directory not found yet (will be created during build)" -Level "INFO"
}

# Check for GitHub CLI
try {
    $ghVersion = gh --version
    Write-Log -Message "GitHub CLI found: $ghVersion" -Level "INFO"
}
catch {
    Write-Log -Message "GitHub CLI (gh) is not installed" -Level "ERROR"
    Write-Log -Message "Please install GitHub CLI from: https://cli.github.com/" -Level "ERROR"
    exit 1
}

# Check if user is logged in to GitHub CLI
try {
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Log -Message "Not authenticated with GitHub CLI" -Level "ERROR"
        Write-Log -Message "Please run 'gh auth login' first" -Level "ERROR"
        exit 1
    }
    Write-Log -Message "GitHub CLI authentication verified" -Level "SUCCESS"
}
catch {
    Write-Log -Message "Error checking GitHub CLI authentication" -Level "ERROR"
    exit 1
}

# Get GitHub username automatically from GitHub CLI
try {
    Write-Log -Message "Getting GitHub username from GitHub CLI" -Level "INFO"
    # Use PowerShell to parse the GitHub username from gh api response
    $userJson = gh api user | ConvertFrom-Json
    $GithubUsername = $userJson.login
    
    if (-not $GithubUsername) {
        Write-Log -Message "Failed to get GitHub username from CLI" -Level "ERROR"
        exit 1
    }
    
    Write-Log -Message "GitHub username detected: $GithubUsername" -Level "SUCCESS"
    
    # Update repo name with correct username
    $RepoName = "$GithubUsername-landing-page-clean"
    Write-Log -Message "Repository name set to: $RepoName" -Level "INFO"
}
catch {
    Write-Log -Message "Error getting GitHub username: $_" -Level "ERROR"
    exit 1
}

# Make sure we're in the right directory
Set-Location -Path $PSScriptRoot
Write-Log -Message "Working in directory: $PSScriptRoot" -Level "INFO"

# Check for Git and npm
try {
    $gitVersion = git --version
    $npmVersion = npm --version
    Write-Log -Message "Git version: $gitVersion" -Level "INFO"
    Write-Log -Message "NPM version: $npmVersion" -Level "INFO"
}
catch {
    Write-Log -Message "Git or NPM is not installed" -Level "ERROR"
    exit 1
}

# Create GitHub repository using GitHub CLI
Write-Log -Message "Creating GitHub repository: $RepoName" -Level "INFO"
try {
    # Check if repo exists
    $repoExists = $false
    $repoCheck = gh repo view "$GithubUsername/$RepoName" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Log -Message "Repository already exists: $GithubUsername/$RepoName" -Level "INFO"
        $repoExists = $true
    }
    
    if (-not $repoExists) {
        # Create the repo
        gh repo create $RepoName --public --description "DevOps Visions landing page clean implementation"
        if ($LASTEXITCODE -ne 0) {
            Write-Log -Message "Failed to create repository" -Level "WARNING"
            Write-Log -Message "Continuing anyway - will attempt to push" -Level "INFO"
        } else {
            Write-Log -Message "Repository created successfully" -Level "SUCCESS"
        }
    }
}
catch {
    Write-Log -Message "Error with repository operation: $_" -Level "WARNING"
    Write-Log -Message "Continuing anyway" -Level "INFO"
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
    Write-Log -Message "Updated remote URL to: https://github.com/$GithubUsername/$RepoName.git" -Level "INFO"
}
else {
    git remote add origin "https://github.com/$GithubUsername/$RepoName.git"
    Write-Log -Message "Added remote origin: https://github.com/$GithubUsername/$RepoName.git" -Level "INFO"
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
    $updatedConfig = $viteConfig -replace 'base:\s*[''"].*[''"]', "base: '/$RepoName/'"
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

# Add the dist directory to Git safe.directory after it's created
$distPath = Join-Path -Path $PSScriptRoot -ChildPath "dist"
git config --global --add safe.directory $distPath
Write-Log -Message "Added newly created dist directory to safe.directory" -Level "SUCCESS"

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

# Push to gh-pages branch using GitHub CLI authentication
Write-Log -Message "Pushing to gh-pages branch" -Level "INFO"
git push -f "https://github.com/$GithubUsername/$RepoName.git" main:gh-pages
if ($LASTEXITCODE -ne 0) {
    # If direct push fails, try using GitHub CLI to authenticate the push
    Write-Log -Message "Direct push failed, trying with GitHub CLI" -Level "WARNING"
    
    # Create temporary credential helper that uses gh auth token
    git config --local credential.helper "!f() { echo \"username=$GithubUsername\"; echo \"password=$(gh auth token)\"; }; f"
    
    # Try pushing again
    git push -f "https://github.com/$GithubUsername/$RepoName.git" main:gh-pages
    if ($LASTEXITCODE -ne 0) {
        Write-Log -Message "Failed to push to gh-pages branch" -Level "ERROR"
        # Revert credential helper
        git config --local --unset credential.helper
        Pop-Location # Return to project root
        exit 1
    }
    
    # Revert credential helper
    git config --local --unset credential.helper
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
GitHub Username: $GithubUsername
Repository: https://github.com/$GithubUsername/$RepoName
Site URL: https://$GithubUsername.github.io/$RepoName/
"@
$successContent | Out-File -FilePath "github_deployment_success_$timestamp.txt"

Write-Log -Message "Success marker created: github_deployment_success_$timestamp.txt" -Level "SUCCESS"
