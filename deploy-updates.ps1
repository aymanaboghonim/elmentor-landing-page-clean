# Deploy Branding and Link Updates to GitHub Pages

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting deployment of Elmentor Landing Page with branding fixes..." -ForegroundColor Cyan
Write-Host ""

# Check for build directory and clean if exists
if (Test-Path -Path ".\dist") {
    Write-Host "🧹 Cleaning up previous build..." -ForegroundColor Yellow
    Remove-Item -Path ".\dist" -Recurse -Force
}

# Build the project
Write-Host "🔨 Building the project..." -ForegroundColor Cyan
npm run build

if (-not (Test-Path -Path ".\dist")) {
    Write-Host "❌ Build failed! Cannot proceed with deployment." -ForegroundColor Red
    exit 1
}

# Verify base path in index.html
$indexHtml = Get-Content -Path ".\dist\index.html" -Raw
if (-not ($indexHtml -match "/elmentor-landing-page-clean/assets/")) {
    Write-Host "⚠️ Warning: Base path may not be set correctly in index.html." -ForegroundColor Yellow
    
    $proceed = Read-Host -Prompt "Do you want to proceed with deployment anyway? (y/n)"
    if ($proceed -ne "y") {
        Write-Host "❌ Deployment canceled." -ForegroundColor Red
        exit 0
    }
}

# Deploy using gh-pages
Write-Host "🚀 Deploying to GitHub Pages..." -ForegroundColor Cyan
npm run deploy:gh-pages

# Check deployment result
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Deployment failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
Write-Host "🌐 Site should be available at: https://aymanaboghonim.github.io/elmentor-landing-page-clean/" -ForegroundColor Cyan
Write-Host "   Please allow a few minutes for GitHub Pages to update." -ForegroundColor White
Write-Host ""
Write-Host "📋 Updated items:" -ForegroundColor Cyan
Write-Host "  1. GitHub links now point to ElmentorProgram repository" -ForegroundColor White
Write-Host "  2. Facebook link corrected for Eng Mohamed Radwan" -ForegroundColor White
Write-Host "  3. Standardized 'Elmentor Program' naming (as one word)" -ForegroundColor White
Write-Host "  4. Benefits section updated with correct entity references" -ForegroundColor White
