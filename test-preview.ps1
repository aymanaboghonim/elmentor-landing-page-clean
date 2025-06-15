# Test Preview Script for Landing Page

Write-Host "🔧 Running a complete test of build and preview..." -ForegroundColor Yellow

# Make sure we're in the project directory
Set-Location -Path "D:\Github_personal\elmentor-landing-page-clean"

# Clean up any previous build
if (Test-Path -Path ".\dist") {
    Write-Host "🗑️ Cleaning up previous build..." -ForegroundColor Gray
    Remove-Item -Path ".\dist" -Recurse -Force
}

# Build the project
Write-Host "🔨 Building the project..." -ForegroundColor Cyan
npm run build

# Check if build was successful
if (-not (Test-Path -Path ".\dist")) {
    Write-Host "❌ Build failed! No dist folder found." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build completed successfully." -ForegroundColor Green

# Start preview server in the background
Write-Host "🚀 Starting preview server..." -ForegroundColor Cyan
$previewProcess = Start-Process -FilePath "npm" -ArgumentList "run", "preview" -PassThru -NoNewWindow

# Give the server a moment to start
Start-Sleep -Seconds 3

Write-Host "🌐 Preview server should be running at:" -ForegroundColor Green
Write-Host "http://localhost:4173/elmentor-landing-page-clean/" -ForegroundColor Cyan

Write-Host "📋 Testing instructions:" -ForegroundColor Yellow
Write-Host "1. Open the URL above in your browser" -ForegroundColor White
Write-Host "2. Verify that the landing page loads properly" -ForegroundColor White
Write-Host "3. Test the navigation links to ensure they scroll to the correct sections" -ForegroundColor White
Write-Host "4. Check that the site looks visually correct" -ForegroundColor White
Write-Host "5. Press Ctrl+C when you're done testing to stop the server" -ForegroundColor White

# Wait for user to press a key
Write-Host "`nPress any key to stop the preview server..." -ForegroundColor Magenta
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Stop the preview server
Write-Host "🛑 Stopping preview server..." -ForegroundColor Yellow
Stop-Process -Id $previewProcess.Id -Force

Write-Host "✨ Test complete!" -ForegroundColor Green
