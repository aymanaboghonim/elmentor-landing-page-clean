# Repository Maintenance Script
# Purpose: Performs maintenance tasks on the repository

# Clean node_modules and reinstall dependencies
Write-Output "Cleaning node_modules..."
if (Test-Path node_modules) {
    Remove-Item -Recurse -Force node_modules
}

# Reinstall dependencies
Write-Output "Reinstalling dependencies..."
npm install

# Clean dist directory
Write-Output "Cleaning dist directory..."
if (Test-Path dist) {
    Remove-Item -Recurse -Force dist
}

# Rebuild
Write-Output "Rebuilding project..."
npm run build

Write-Output "Maintenance complete!"
