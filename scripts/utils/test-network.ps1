# Test Visual Consistency Across Devices - Simple Version

Write-Host "📋 Visual Consistency Test Checklist:" -ForegroundColor Cyan
Write-Host "  □ News Section: Verify year archive buttons work correctly" -ForegroundColor White
Write-Host "  □ Backgrounds: Check for consistent appearance across sections" -ForegroundColor White
Write-Host "  □ Navbar: Test gradient appearance in both initial and scrolled states" -ForegroundColor White
Write-Host "  □ Text: Verify all 'DevOps Visions Public Community' references" -ForegroundColor White
Write-Host "  □ Responsive: Test on mobile, tablet, and desktop viewports" -ForegroundColor White
Write-Host ""

# Start the preview server with host flag
Write-Host "🚀 Starting preview server with network access..." -ForegroundColor Cyan
npm run preview -- --host
