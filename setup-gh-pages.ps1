# Install and Setup gh-pages for Deployment

# Make sure we're in the project directory
cd d:\Github_personal\elmentor-landing-page-clean

# Install gh-pages as a dev dependency
npm install --save-dev gh-pages

# Add a deploy script to package.json
# This will update the deploy script to use gh-pages
$packageJsonPath = "d:\Github_personal\elmentor-landing-page-clean\package.json"
$packageJson = Get-Content $packageJsonPath -Raw | ConvertFrom-Json

# Add the new script if it doesn't exist
if (-not ($packageJson.scripts.PSObject.Properties.Name -contains "deploy:gh-pages")) {
    $packageJson.scripts | Add-Member -Name "deploy:gh-pages" -Value "gh-pages -d dist" -MemberType NoteProperty
}

# Save the updated package.json
$packageJson | ConvertTo-Json -Depth 10 | Set-Content -Path $packageJsonPath

Write-Host "✅ gh-pages installed and deploy script added!" -ForegroundColor Green
Write-Host "📋 Usage instructions:" -ForegroundColor Cyan
Write-Host "1. Build the project: npm run build" -ForegroundColor Cyan
Write-Host "2. Deploy to GitHub Pages: npm run deploy:gh-pages" -ForegroundColor Cyan
