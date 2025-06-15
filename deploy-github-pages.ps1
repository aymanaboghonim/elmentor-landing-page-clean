#!/usr/bin/env pwsh
# GitHub Pages deployment script for Elmentor Landing Page

# Abort on errors
$ErrorActionPreference = "Stop"

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

# Create or update .nojekyll file (prevents Jekyll processing)
Write-Host "Creating .nojekyll file..." -ForegroundColor Yellow
New-Item -ItemType File -Path ".nojekyll" -Force | Out-Null

# If you are deploying to a custom domain
# Set-Content -Path "CNAME" -Value "www.your-domain.com"

# Initialize Git repo
Write-Host "Initializing Git repository..." -ForegroundColor Yellow
git init
git add -A

# Commit changes
Write-Host "Committing changes..." -ForegroundColor Yellow
git commit -m "Deploy to GitHub Pages"

# Force push to the gh-pages branch
# IMPORTANT: Update the repository URL below with your actual GitHub repository URL
Write-Host "Pushing to GitHub Pages..." -ForegroundColor Yellow
$repoUrl = "git@github.com:elmentor/elmentor-landing-page-clean.git"
git push -f $repoUrl main:gh-pages

# Return to the project root
Set-Location -Path $PSScriptRoot

Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host "Your site should be available at: https://yourusername.github.io/elmentor-landing-page-clean/" -ForegroundColor Cyan
