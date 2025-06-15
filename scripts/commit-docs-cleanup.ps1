# Script to commit documentation cleanup changes

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🧹 Committing documentation cleanup changes..." -ForegroundColor Cyan

# Add all changed files
git add .

# Commit with a descriptive message
git commit -m "Documentation: Cleanup and organization of markdown files

- Created structured documentation directories (deployment, development, design, legacy)
- Consolidated similar documentation files
- Created comprehensive guides for deployment, development, and design
- Moved legacy/outdated documentation to a separate directory
- Updated documentation index with proper links"

# Show commit status
Write-Host "✅ Documentation cleanup committed successfully!" -ForegroundColor Green
Write-Host "Run 'git push origin master' to push changes to GitHub" -ForegroundColor Yellow
