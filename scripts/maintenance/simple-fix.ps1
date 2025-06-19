#!/usr/bin/env pwsh
# Simple script to fix GitHub Pages deployment

# Make sure we're in the right directory
Set-Location -Path $PSScriptRoot

# Update vite.config.ts
$viteConfig = Get-Content -Path "vite.config.ts" -Raw
$viteConfig = $viteConfig -replace "base: '.*'", "base: '/elmentor-landing-page-clean/'"
Set-Content -Path "vite.config.ts" -Value $viteConfig -NoNewline
Write-Host "Updated vite.config.ts with correct base path"

# Build the project
Write-Host "Building project..."
npm run build

# Move to the dist directory
Set-Location -Path "dist"

# Create .nojekyll file to bypass Jekyll processing
$null > .nojekyll
Write-Host "Created .nojekyll file"

# Initialize Git repository
Write-Host "Initializing Git repository..."
git init
git add -A
git commit -m "Deploy to GitHub Pages"

# Force push to the gh-pages branch of your GitHub repository
Write-Host "Pushing to GitHub Pages..."
git push -f https://github.com/aymanaboghonim/elmentor-landing-page-clean.git master:gh-pages

Write-Host "Deployment completed! Your site should be available at: https://aymanaboghonim.github.io/elmentor-landing-page-clean/"
