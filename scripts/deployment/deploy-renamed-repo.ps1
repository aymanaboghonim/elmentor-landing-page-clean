#!/usr/bin/env pwsh
# Direct deployment script for the renamed repository

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
    Add-Content -Path "renamed-repo-deploy.log" -Value $logMessage
    
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

# Repository name
$RepoName = "elmentor-landing-page-clean"
$CommitMessage = "Deployment to renamed repository"

# Start logging
Write-Log -Message "Starting deployment to renamed repository" -Level "INFO"

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
    gh auth status 2>&1 | Out-Null
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

# Make sure we're in the right directory
$repoPath = (Get-Location).Path
Write-Log -Message "Working in directory: $repoPath" -Level "INFO"

# Verify the repository exists and is properly renamed
Write-Log -Message "Verifying repository: $GithubUsername/$RepoName" -Level "INFO"
try {
    $repoCheck = gh repo view "$GithubUsername/$RepoName" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Log -Message "Repository exists: $GithubUsername/$RepoName" -Level "SUCCESS"
    } else {
        Write-Log -Message "Repository not found: $GithubUsername/$RepoName" -Level "ERROR"
        exit 1
    }
}
catch {
    Write-Log -Message "Error checking repository: $_" -Level "ERROR"
    exit 1
}

# Verify Git configuration
Write-Log -Message "Verifying Git configuration" -Level "INFO"
$remoteUrl = git remote get-url origin
if ($remoteUrl -eq "https://github.com/$GithubUsername/$RepoName.git") {
    Write-Log -Message "Git remote correctly configured: $remoteUrl" -Level "SUCCESS"
} else {
    Write-Log -Message "Updating Git remote URL" -Level "INFO"
    git remote set-url origin "https://github.com/$GithubUsername/$RepoName.git"
    if ($LASTEXITCODE -eq 0) {
        Write-Log -Message "Git remote URL updated to: https://github.com/$GithubUsername/$RepoName.git" -Level "SUCCESS"
    } else {
        Write-Log -Message "Failed to update Git remote URL" -Level "ERROR"
        exit 1
    }
}

# Update vite.config.ts for GitHub Pages
Write-Log -Message "Checking vite.config.ts for GitHub Pages" -Level "INFO"
$viteConfigPath = "vite.config.ts"
if (Test-Path -Path $viteConfigPath) {
    $viteConfig = Get-Content -Path $viteConfigPath -Raw
    $basePathPattern = [regex]::Escape("/$RepoName/")
    if (-not ($viteConfig -match $basePathPattern)) {
        Write-Log -Message "Updating vite.config.ts with correct base path" -Level "INFO"
        $updatedConfig = $viteConfig -replace 'base:\s*".*"', "base: `"/$RepoName/`""
        Set-Content -Path $viteConfigPath -Value $updatedConfig -NoNewline
        Write-Log -Message "Updated vite.config.ts with base path: /$RepoName/" -Level "SUCCESS"
    } else {
        Write-Log -Message "vite.config.ts already has correct base path: /$RepoName/" -Level "SUCCESS"
    }
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

# Deploy to GitHub Pages using a temporary directory
Write-Log -Message "Preparing for GitHub Pages deployment" -Level "INFO"
$tempDir = Join-Path -Path $env:TEMP -ChildPath "gh-pages-deploy-$([Guid]::NewGuid().ToString())"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    # Copy dist contents to temp directory
    Write-Log -Message "Copying build files to temporary directory" -Level "INFO"
    Copy-Item -Path "$repoPath\dist\*" -Destination $tempDir -Recurse -Force
    
    # Create .nojekyll file
    New-Item -ItemType File -Path "$tempDir\.nojekyll" -Force | Out-Null
    Write-Log -Message "Created .nojekyll file" -Level "INFO"
    
    # Initialize git in temp directory
    Set-Location -Path $tempDir
    Write-Log -Message "Initializing Git in temporary directory" -Level "INFO"
    git init
    git add -A
    git commit -m $CommitMessage
    
    # Set remote and push
    Write-Log -Message "Setting up remote and pushing to gh-pages branch" -Level "INFO"
    git remote add origin "https://github.com/$GithubUsername/$RepoName.git"
    
    # Push using GitHub CLI token for authentication
    Write-Log -Message "Pushing to gh-pages branch using GitHub CLI token" -Level "INFO"
    $token = gh auth token
    
    # Use token for pushing
    $env:GIT_ASKPASS = "echo"
    $env:GIT_USERNAME = $GithubUsername
    $env:GIT_PASSWORD = $token
    
    git push -f origin master:gh-pages
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log -Message "Successfully pushed to gh-pages branch" -Level "SUCCESS"
    } else {
        Write-Log -Message "Failed to push to gh-pages branch" -Level "ERROR"
        exit 1
    }
    
    # Return to original directory
    Set-Location -Path $repoPath
    
    # Final status
    Write-Log -Message "Deployment to renamed repository completed" -Level "SUCCESS"
    Write-Log -Message "Site URL: https://$GithubUsername.github.io/$RepoName/" -Level "SUCCESS"
    
    # Create success marker file
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $successContent = @"
Deployment to renamed repository completed successfully at $(Get-Date)
GitHub Username: $GithubUsername
Repository: https://github.com/$GithubUsername/$RepoName
Site URL: https://$GithubUsername.github.io/$RepoName/
"@
    $successContent | Out-File -FilePath "renamed_repo_success_$timestamp.txt"
    
    Write-Log -Message "Success marker created: renamed_repo_success_$timestamp.txt" -Level "SUCCESS"
}
catch {
    Write-Log -Message "Error during deployment: $_" -Level "ERROR"
    
    # Return to original directory
    Set-Location -Path $repoPath
    exit 1
}
finally {
    # Clean up temp directory
    if (Test-Path -Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log -Message "Cleaned up temporary directory" -Level "INFO"
    }
}
