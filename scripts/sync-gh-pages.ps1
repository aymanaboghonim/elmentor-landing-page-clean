# Script to keep gh-pages deployment in sync with master

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🔄 Syncing GitHub Pages with master branch" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the repo root
if (-not (Test-Path ".git")) {
    Write-Host "❌ Please run this script from the repository root." -ForegroundColor Red
    exit 1
}

# Ensure we're on master branch
Write-Host "🔄 Switching to master branch..." -ForegroundColor Cyan
git checkout master
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to switch to master branch. Please resolve any conflicts first." -ForegroundColor Red
    exit 1
}

# Pull latest changes from master
Write-Host "🔄 Pulling latest changes from master..." -ForegroundColor Cyan
git pull origin master
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to pull from master. Please resolve any conflicts first." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Master branch updated" -ForegroundColor Green

# Build the project (this generates the dist folder)
Write-Host "🏗️ Building the project..." -ForegroundColor Cyan
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed! Fix the issues before deploying." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Build completed successfully" -ForegroundColor Green

# Deploy to gh-pages
Write-Host "🚀 Deploying to gh-pages..." -ForegroundColor Cyan
npm run deploy:gh-pages
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Deployment to gh-pages failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Deployed to gh-pages successfully" -ForegroundColor Green

Write-Host "`n🎉 GitHub Pages successfully updated with latest master changes!" -ForegroundColor Green
Write-Host "🌐 Site should be available at: https://aymanaboghonim.github.io/elmentor-landing-page-clean/" -ForegroundColor Cyan
Write-Host "   Please allow a few minutes for GitHub Pages to update." -ForegroundColor White
