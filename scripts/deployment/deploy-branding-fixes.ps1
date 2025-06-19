# Deploy with Branding Fixes

# Check for build directory and clean if exists
if (Test-Path -Path ".\dist") {
    Write-Host "🧹 Cleaning up previous build..." -ForegroundColor Yellow
    Remove-Item -Path ".\dist" -Recurse -Force
}

# Document the updates
Write-Host "📝 Branding and Link Consistency Updates:" -ForegroundColor Cyan
Write-Host "  ✓ Updated GitHub links to point to ElmentorProgram repository" -ForegroundColor Green
Write-Host "  ✓ Corrected Facebook link for Eng Mohamed Radwan" -ForegroundColor Green
Write-Host "  ✓ Standardized naming of 'Elmentor Program' (as one word)" -ForegroundColor Green
Write-Host "  ✓ Updated references in Benefits section" -ForegroundColor Green
Write-Host ""

# Build the project
Write-Host "🔨 Building the project with branding fixes..." -ForegroundColor Cyan
npm run build

if (-not (Test-Path -Path ".\dist")) {
    Write-Host "❌ Build failed! Cannot proceed with deployment." -ForegroundColor Red
    exit 1
}

# Verify that index.html exists and contains the correct base path
$indexHtml = Get-Content -Path ".\dist\index.html" -Raw
if (-not ($indexHtml -match "/elmentor-landing-page-clean/assets/")) {
    Write-Host "⚠️ Warning: Base path may not be correctly set in index.html." -ForegroundColor Yellow
    Write-Host "   Please verify the build output before deploying." -ForegroundColor Yellow
    
    $continue = Read-Host -Prompt "Continue with deployment? (y/n)"
    if ($continue -ne "y") {
        Write-Host "❌ Deployment canceled." -ForegroundColor Red
        exit 0
    }
}

# Deploy using gh-pages
Write-Host "🚀 Deploying to GitHub Pages with branding fixes..." -ForegroundColor Cyan
npm run deploy:gh-pages

Write-Host "✅ Deployment completed!" -ForegroundColor Green
Write-Host "🌐 Site should be available at: https://aymanaboghonim.github.io/elmentor-landing-page-clean/" -ForegroundColor Cyan
Write-Host "   Please allow a few minutes for GitHub Pages to update." -ForegroundColor White
Write-Host ""
Write-Host "📋 Changes Summary:" -ForegroundColor Cyan
Write-Host "  1. All GitHub repository links now point to ElmentorProgram (https://github.com/ElmentorProgram)" -ForegroundColor White
Write-Host "  2. Facebook link updated to correct URL: https://www.facebook.com/mradwandevops" -ForegroundColor White
Write-Host "  3. 'El Mentor' updated to 'Elmentor' (one word) throughout the site" -ForegroundColor White
Write-Host "  4. Updated references in Benefits section from DevOps Visions to Elmentor Program" -ForegroundColor White
