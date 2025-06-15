# Test Visual Consistency Across Devices - Simple Version

# Build the project
Write-Host "🔨 Building the project..." -ForegroundColor Cyan
npm run build

if (-not (Test-Path -Path ".\dist")) {
    Write-Host "❌ Build failed! Cannot proceed with testing." -ForegroundColor Red
    exit 1
}

# Start the preview server
Write-Host "🚀 Starting preview server..." -ForegroundColor Cyan
npm run preview -- --host

# Note: This script will keep running until you stop it with Ctrl+C
# The npm run preview command will show the URLs for local and network testing
