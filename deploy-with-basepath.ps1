# Deploy with Base Path Fix

# Check for build directory and clean if exists
if (Test-Path -Path ".\dist") {
    Write-Host "🧹 Cleaning up previous build..." -ForegroundColor Yellow
    Remove-Item -Path ".\dist" -Recurse -Force
}

# Build the project
Write-Host "🔨 Building the project with correct base path..." -ForegroundColor Cyan
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
Write-Host "🚀 Deploying to GitHub Pages..." -ForegroundColor Cyan
npm run deploy:gh-pages

Write-Host "✅ Deployment completed!" -ForegroundColor Green
Write-Host "🌐 Site should be available at: https://aymanaboghonim.github.io/elmentor-landing-page-clean/" -ForegroundColor Cyan
Write-Host "   Please allow a few minutes for GitHub Pages to update." -ForegroundColor White
