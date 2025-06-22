# Test Deployment Script
# Purpose: Tests the deployment process without actually deploying

# Load GitHub username from config
$githubUsername = Get-Content -Path "github-config.txt" -TotalCount 1

Write-Output "==== DEPLOYMENT TEST MODE ===="
Write-Output "GitHub Username: $githubUsername"
Write-Output "Repository: elmentor-landing-page-clean"
Write-Output "Target URL: https://$githubUsername.github.io/elmentor-landing-page-clean/"

Write-Output "`n==== VALIDATING CONFIGURATION ===="

# Check if git is available
try {
    $gitVersion = git --version
    Write-Output "✓ Git is available: $gitVersion"
} catch {
    Write-Output "✗ Git is not available in PATH. Please install Git."
    exit 1
}

# Check if npm is available
try {
    $npmVersion = npm --version
    Write-Output "✓ npm is available: v$npmVersion"
} catch {
    Write-Output "✗ npm is not available in PATH. Please install Node.js."
    exit 1
}

# Check if package.json exists
if (Test-Path "package.json") {
    Write-Output "✓ package.json found"
} else {
    Write-Output "✗ package.json not found. Are you in the correct directory?"
    exit 1
}

# Check if the build script exists in package.json
$packageJson = Get-Content -Path "package.json" | ConvertFrom-Json
if ($packageJson.scripts.build) {
    Write-Output "✓ Build script found in package.json"
} else {
    Write-Output "✗ Build script not found in package.json."
    exit 1
}

Write-Output "`n==== TEST BUILD SIMULATION ===="
Write-Output "Would execute: npm run build"
Write-Output "This would generate the static site in the /dist directory"

Write-Output "`n==== TEST DEPLOYMENT SIMULATION ===="
Write-Output "Would execute: npx gh-pages -d dist -r https://github.com/$githubUsername/elmentor-landing-page-clean.git"
Write-Output "This would deploy the /dist directory to GitHub Pages"

Write-Output "`n==== TEST COMPLETE ===="
Write-Output "Deployment test successful! In a real deployment, your site would be live at:"
Write-Output "https://$githubUsername.github.io/elmentor-landing-page-clean/"
