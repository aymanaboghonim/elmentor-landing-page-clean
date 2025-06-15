#!/usr/bin/env pwsh
# Simplified GitHub Pages deployment script for Elmentor Landing Page
# This script uses a more reliable approach for deployment

# Abort on errors
$ErrorActionPreference = "Stop"

# Make sure we're in the right directory
Set-Location -Path $PSScriptRoot

# Clear the console
Clear-Host

Write-Host "===== ELMENTOR LANDING PAGE - SIMPLIFIED DEPLOYMENT =====" -ForegroundColor Cyan
Write-Host ""

# Clean build artifacts
if (Test-Path -Path ".\dist") {
    Write-Host "Cleaning previous build..." -ForegroundColor Yellow
    Remove-Item -Path ".\dist" -Recurse -Force
}

# Build the project
Write-Host "Building project..." -ForegroundColor Yellow
npm run build
if (-not $?) {
    Write-Host "Build failed! Aborting deployment." -ForegroundColor Red
    exit 1
}
Write-Host "Build completed successfully." -ForegroundColor Green

# Create deployment directory if it doesn't exist
$deployDir = ".\deploy-gh-pages"
if (-not (Test-Path -Path $deployDir)) {
    Write-Host "Creating deployment directory..." -ForegroundColor Yellow
    New-Item -Path $deployDir -ItemType Directory | Out-Null
}
else {
    Write-Host "Cleaning deployment directory..." -ForegroundColor Yellow
    Remove-Item -Path "$deployDir\*" -Recurse -Force
}

# Copy build files to deployment directory
Write-Host "Copying build files to deployment directory..." -ForegroundColor Yellow
Copy-Item -Path ".\dist\*" -Destination $deployDir -Recurse -Force

# Create .nojekyll file
Write-Host "Creating .nojekyll file..." -ForegroundColor Yellow
New-Item -ItemType File -Path "$deployDir\.nojekyll" -Force | Out-Null

# Get GitHub username
$githubUsername = "aymanaboghonim"  # Default
try {
    $remoteUrl = git config --get remote.origin.url
    if ($remoteUrl -match "github\.com[:/]([^/]+)/") {
        $githubUsername = $Matches[1]
        Write-Host "Detected GitHub username: $githubUsername" -ForegroundColor Green
    }
}
catch {
    Write-Host "Could not detect GitHub username. Using default: $githubUsername" -ForegroundColor Yellow
}

# Use gh CLI if available
$useGhCli = $false
try {
    $ghVersion = gh --version
    if ($?) {
        $useGhCli = $true
        Write-Host "GitHub CLI detected. Will use for deployment." -ForegroundColor Green
    }
}
catch {
    Write-Host "GitHub CLI not found. Will use git push method." -ForegroundColor Yellow
}

if ($useGhCli) {
    # Deploy using GitHub CLI
    Write-Host "Deploying to GitHub Pages using GitHub CLI..." -ForegroundColor Yellow
    Set-Location -Path $deployDir
    
    # Try to deploy using gh
    try {
        gh auth status | Out-Null
        if ($?) {
            # User is already authenticated
            gh pages deploy . --repo "$githubUsername/elmentor-landing-page-clean"
            if ($?) {
                Write-Host "Deployment successful!" -ForegroundColor Green
            }
            else {
                throw "GitHub CLI deployment failed."
            }
        }
        else {
            throw "Not authenticated with GitHub CLI."
        }
    }
    catch {
        Write-Host "GitHub CLI deployment failed. Falling back to git push method." -ForegroundColor Yellow
        $useGhCli = $false
    }
    
    # Return to project root
    Set-Location -Path $PSScriptRoot
}

if (-not $useGhCli) {
    # Deploy using git push method
    Write-Host "Deploying to GitHub Pages using git push method..." -ForegroundColor Yellow
    
    # Initialize temporary git repo
    Set-Location -Path $deployDir
    git init -b main
    git add .
    git config user.name "GitHub Actions"
    git config user.email "actions@github.com"
    git commit -m "Deploy to GitHub Pages - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    
    # Try pushing to gh-pages branch
    try {
        git remote add origin "https://github.com/$githubUsername/elmentor-landing-page-clean.git"
        git push -f origin main:gh-pages
        Write-Host "Deployment successful!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to push to GitHub. Please check your credentials and permissions." -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        exit 1
    }
    
    # Return to project root
    Set-Location -Path $PSScriptRoot
}

Write-Host ""
Write-Host "===== DEPLOYMENT COMPLETED =====" -ForegroundColor Green
Write-Host ""
Write-Host "Your site should be available at:" -ForegroundColor Cyan
Write-Host "https://$githubUsername.github.io/elmentor-landing-page-clean/" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host ""
Write-Host "Please allow a few minutes for GitHub Pages to process the deployment." -ForegroundColor Yellow
