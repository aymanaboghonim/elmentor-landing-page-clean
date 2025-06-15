# Deploy with Visual Consistency Updates

# Check for build directory and clean if exists
if (Test-Path -Path ".\dist") {
    Write-Host "🧹 Cleaning up previous build..." -ForegroundColor Yellow
    Remove-Item -Path ".\dist" -Recurse -Force
}

# Document the updates
Write-Host "📝 Visual Consistency Updates:" -ForegroundColor Cyan
Write-Host "  ✓ News Section: Year-based archive (2023, 2024, 2025)" -ForegroundColor Green
Write-Host "  ✓ Background Color: Unified across sections" -ForegroundColor Green
Write-Host "  ✓ Navbar: Improved gradient background" -ForegroundColor Green
Write-Host "  ✓ Terminology: Updated DevOps Visions Public Community references" -ForegroundColor Green
Write-Host ""

# Build the project
Write-Host "🔨 Building the project with visual consistency updates..." -ForegroundColor Cyan
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
Write-Host "🚀 Deploying to GitHub Pages with visual consistency updates..." -ForegroundColor Cyan
npm run deploy:gh-pages

Write-Host "✅ Deployment completed!" -ForegroundColor Green
Write-Host "🌐 Site should be available at: https://aymanaboghonim.github.io/elmentor-landing-page-clean/" -ForegroundColor Cyan
Write-Host "   Please allow a few minutes for GitHub Pages to update." -ForegroundColor White
Write-Host ""
Write-Host "📋 Changes Summary:" -ForegroundColor Cyan
Write-Host "  1. News Section now shows year-based archives (2023, 2024, 2025)" -ForegroundColor White
Write-Host "  2. Background colors unified across all sections for visual consistency" -ForegroundColor White
Write-Host "  3. Navbar background improved with professional gradient" -ForegroundColor White
Write-Host "  4. Updated terminology from 'DevOps Visions Program Official Channels'" -ForegroundColor White
Write-Host "     to 'DevOps Visions Public Community'" -ForegroundColor White
