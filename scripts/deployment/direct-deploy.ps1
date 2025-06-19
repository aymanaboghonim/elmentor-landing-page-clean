#!/usr/bin/env pwsh
# Direct deployment script that uses gh-pages branch without Git in dist directory

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
    Add-Content -Path "direct-deploy.log" -Value $logMessage
    
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
Write-Log -Message "Starting direct deployment process" -Level "INFO"

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
    $RepoName = "$GithubUsername-landing-page-clean"
    Write-Log -Message "Repository name set to: $RepoName" -Level "INFO"
}
catch {
    Write-Log -Message "Error getting GitHub username: $_" -Level "ERROR"
    exit 1
}

# Make sure we're in the right directory
Set-Location -Path $PSScriptRoot
$repoPath = (Get-Location).Path
Write-Log -Message "Working in directory: $repoPath" -Level "INFO"

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

# Create GitHub repository if it doesn't exist
Write-Log -Message "Checking GitHub repository: $RepoName" -Level "INFO"
try {
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

# Create a temporary directory for gh-pages branch
Write-Log -Message "Creating temporary directory for gh-pages deployment" -Level "INFO"
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
    git commit -m "Automated deployment"
    
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
    $successContent | Out-File -FilePath "direct_deployment_success_$timestamp.txt"
    
    Write-Log -Message "Success marker created: direct_deployment_success_$timestamp.txt" -Level "SUCCESS"
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
