#!/usr/bin/env pwsh
# Simple GitHub Pages deployment script

param(
    [Parameter(Mandatory=$false)]
    [string]$GithubUsername = ""
)

# If username wasn't provided, prompt for it
if ([string]::IsNullOrEmpty($GithubUsername)) {
    $GithubUsername = Read-Host "Enter your GitHub username"
}

if ([string]::IsNullOrEmpty($GithubUsername)) {
    Write-Host "Error: GitHub username cannot be empty." -ForegroundColor Red
    exit 1
}

# Make sure we're in the right directory
Set-Location -Path $PSScriptRoot

Write-Host "Starting GitHub Pages deployment..." -ForegroundColor Cyan

# Build the project
Write-Host "Building project..." -ForegroundColor Yellow
npm run build
if (-not $?) {
    Write-Host "Build failed! Aborting deployment." -ForegroundColor Red
    exit 1
}

# Navigate into the build output directory
Set-Location -Path ".\dist"

# Create .nojekyll file (prevents Jekyll processing)
New-Item -ItemType File -Path ".nojekyll" -Force | Out-Null

# Initialize Git repo
Write-Host "Initializing Git in the dist folder..." -ForegroundColor Yellow
git init
git add -A

# Commit changes
git commit -m "Deploy to GitHub Pages"

# Force push to the gh-pages branch
Write-Host "Pushing to GitHub Pages..." -ForegroundColor Yellow
$repoUrl = "https://github.com/$GithubUsername/elmentor-landing-page-clean.git"
git push -f $repoUrl main:gh-pages

# Return to the project root
Set-Location -Path $PSScriptRoot

Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host "Your site should be available at: https://$GithubUsername.github.io/elmentor-landing-page-clean/" -ForegroundColor Cyan
