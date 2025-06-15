# GitHub repository setup and deployment with no user interaction
$GithubUsername = "aymanaboghonim"
$RepoName = "elmentor-landing-page-clean"
$Description = "Clean, maintainable implementation of the aymanaboghonim/DevOps Visions landing page"

# Start log file
$logFile = "github_setup.log"
"[$(Get-Date)] Starting GitHub repository automated setup" | Out-File -FilePath $logFile

# Create success file function
function Create-SuccessFile {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $content = @"
Repository setup completed at $(Get-Date)
Repository URL: https://github.com/$GithubUsername/$RepoName
GitHub Pages URL: https://$GithubUsername.github.io/$RepoName/
"@
    $content | Out-File -FilePath "github_setup_success_$timestamp.txt"
}

# Log function
function Log {
    param($message, $level = "INFO")
    
    $logEntry = "[$(Get-Date)] [$level] $message"
    $logEntry | Out-File -FilePath $logFile -Append
}

# Step 1: Check for Git
Log "Checking Git installation"
try {
    $gitVersion = git --version
    Log "Git found: $gitVersion"
}
catch {
    Log "Git not found. Aborting." "ERROR"
    exit 1
}

# Step 2: Check for GitHub CLI
Log "Checking GitHub CLI installation"
try {
    $ghVersion = gh --version
    Log "GitHub CLI found: $ghVersion"
}
catch {
    Log "GitHub CLI not found. Will attempt basic Git operations." "WARNING"
}

# Step 3: Set basic Git config if needed
$gitUser = git config --global user.name
if (-not $gitUser) {
    git config --global user.name "GitHub Actions"
    Log "Set default Git user name"
}

$gitEmail = git config --global user.email
if (-not $gitEmail) {
    git config --global user.email "github-actions@github.com"
    Log "Set default Git user email"
}

# Step 4: Initialize Git if needed
if (-not (Test-Path ".git")) {
    git init
    Log "Initialized Git repository"
}

# Step 5: Update deployment files
Log "Updating configuration files"

# Update vite.config.ts
$viteConfigPath = "vite.config.ts"
if (Test-Path $viteConfigPath) {
    $viteConfig = Get-Content $viteConfigPath -Raw
    $updated = $viteConfig -replace "base: ['`"].*['`"]", "base: '/$RepoName/'"
    Set-Content -Path $viteConfigPath -Value $updated -NoNewline
    Log "Updated vite.config.ts"
}

# Update deploy script
$deployScriptPath = "deploy-github-pages.ps1"
if (Test-Path $deployScriptPath) {
    $deployScript = Get-Content $deployScriptPath -Raw
    $updated = $deployScript -replace '(\$repoUrl\s*=\s*"git@github\.com:).*(/elmentor-landing-page-clean\.git")', "`$1$GithubUsername`$2"
    Set-Content -Path $deployScriptPath -Value $updated -NoNewline
    Log "Updated deploy-github-pages.ps1"
}

# Update README
$readmePath = "README.md"
if (Test-Path $readmePath) {
    $readme = Get-Content $readmePath -Raw
    $updated = $readme -replace "(https://)[^/]+(\.github\.io/$RepoName/)", "`$1$GithubUsername`$2"
    Set-Content -Path $readmePath -Value $updated -NoNewline
    Log "Updated README.md"
}

# Step 6: Add remote origin
Log "Setting remote origin"
$remotes = git remote
if ($remotes -contains "origin") {
    git remote set-url origin "https://github.com/$GithubUsername/$RepoName.git"
    Log "Updated remote URL"
}
else {
    git remote add origin "https://github.com/$GithubUsername/$RepoName.git"
    Log "Added remote origin"
}

# Step 7: Commit changes
Log "Committing changes"
git add .
git commit -m "Automated setup: Updated repository configuration"

# Step 8: Push to GitHub (this will create repo if using GitHub CLI)
Log "Pushing to GitHub"
try {
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        # Create repo using GitHub CLI if it doesn't exist
        gh repo create $RepoName --public --description $Description --source=. --remote=origin --push
    }
    else {
        # Just try pushing (will fail if repo doesn't exist)
        git push -u origin main
    }
    Log "Successfully pushed to GitHub" "SUCCESS"
}
catch {
    Log "Failed to push to GitHub. Manual creation may be needed." "ERROR"
}

# Step 9: Build project
Log "Building project"
npm run build
if ($LASTEXITCODE -ne 0) {
    Log "Build failed" "ERROR"
    exit 1
}
Log "Build successful" "SUCCESS"

# Step 10: Deploy to GitHub Pages
Log "Deploying to GitHub Pages"
try {
    # Navigate to dist directory
    Push-Location -Path "dist"
    
    # Create .nojekyll file
    "" | Out-File -FilePath ".nojekyll" -NoNewline
    
    # Initialize Git
    git init
    git add .
    git commit -m "Deploy to GitHub Pages"
    
    # Push to gh-pages branch
    git push -f "https://github.com/$GithubUsername/$RepoName.git" main:gh-pages
    
    # Return to original directory
    Pop-Location
    
    Log "Successfully deployed to GitHub Pages" "SUCCESS"
}
catch {
    Log "Failed to deploy to GitHub Pages: $_" "ERROR"
}

# Create success file
Create-SuccessFile
Log "Setup and deployment completed!" "SUCCESS"
