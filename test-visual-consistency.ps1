# Test Visual Consistency Across Devices

Write-Host "🧪 Starting Visual Consistency Testing..." -ForegroundColor Cyan
Write-Host ""

# Build the project
Write-Host "🔨 Building the project..." -ForegroundColor Cyan
npm run build

if (-not (Test-Path -Path ".\dist")) {
    Write-Host "❌ Build failed! Cannot proceed with testing." -ForegroundColor Red
    exit 1
}

# Start the preview server
Write-Host "🚀 Starting preview server..." -ForegroundColor Cyan
$previewProcess = Start-Process -FilePath "npm" -ArgumentList "run", "preview", "--", "--host" -PassThru -NoNewWindow

# Wait a moment for the server to start
Start-Sleep -Seconds 3

# Get the local network IP for testing on other devices
$networkIP = Get-NetIPAddress | Where-Object { 
    $_.AddressFamily -eq 'IPv4' -and 
    $_.PrefixOrigin -eq 'Dhcp' 
} | Select-Object -ExpandProperty IPAddress

Write-Host ""
Write-Host "📱 Testing URLs:" -ForegroundColor Green
Write-Host "   Local:   http://localhost:4173/elmentor-landing-page-clean/" -ForegroundColor White
if ($networkIP) {
    Write-Host "   Network: http://${networkIP}:4173/elmentor-landing-page-clean/" -ForegroundColor White
    Write-Host "   (Use this URL to test on mobile devices connected to the same network)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Visual Consistency Test Checklist:" -ForegroundColor Cyan
Write-Host "  □ News Section: Verify year archive buttons work correctly" -ForegroundColor White
Write-Host "  □ Backgrounds: Check for consistent appearance across sections" -ForegroundColor White
Write-Host "  □ Navbar: Test gradient appearance in both initial and scrolled states" -ForegroundColor White
Write-Host "  □ Text: Verify all 'DevOps Visions Public Community' references" -ForegroundColor White
Write-Host "  □ Responsive: Test on mobile, tablet, and desktop viewports" -ForegroundColor White

Write-Host ""
Write-Host "Press Ctrl+C to stop the test server when finished." -ForegroundColor Yellow

try {
    # Keep the script running until user presses Ctrl+C
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    # Stop the preview process when script exits
    if ($previewProcess -and !$previewProcess.HasExited) {
        $previewProcess | Stop-Process -Force
        Write-Host "✅ Testing server stopped." -ForegroundColor Green
    }
}
