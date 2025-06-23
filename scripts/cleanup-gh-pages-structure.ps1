# Clean GitHub Pages Branch Structure
#
# This script:
# 1. Checks out gh-pages branch
# 2. Keeps only files needed for GitHub Pages
# 3. Adds a proper README.md explaining the branch purpose
# 4. Commits the changes

param (
    [switch]$Force = $false
)

# Safety check
if (-not $Force) {
    Write-Host "WARNING: This script will clean up the gh-pages branch, removing files not needed for deployment." -ForegroundColor Yellow
    Write-Host "Files that will be kept:" -ForegroundColor Cyan
    Write-Host "- index.html" -ForegroundColor Cyan
    Write-Host "- assets/ directory" -ForegroundColor Cyan
    Write-Host "- Static assets (images, etc.)" -ForegroundColor Cyan
    Write-Host "- .nojekyll file" -ForegroundColor Cyan
    Write-Host "- README.md" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "All other files will be DELETED!" -ForegroundColor Red
    
    $confirmation = Read-Host "Do you want to continue? (y/n)"
    if ($confirmation -ne 'y') {
        Write-Host "Operation cancelled." -ForegroundColor Red
        exit 0
    }
}

# Check if we have uncommitted changes
$status = git status --porcelain
if ($status) {
    Write-Host "You have uncommitted changes. Please commit or stash them before running this script." -ForegroundColor Red
    exit 1
}

# Store current branch
$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Host "Current branch: $currentBranch" -ForegroundColor Blue

try {
    # Checkout gh-pages branch
    Write-Host "Checking out gh-pages branch..." -ForegroundColor Blue
    git checkout gh-pages

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to checkout gh-pages branch. Aborting." -ForegroundColor Red
        exit 1
    }

    # Create temp directory
    Write-Host "Creating temporary directory..." -ForegroundColor Blue
    $tempDir = ".\.temp\gh-pages-cleanup"
    if (Test-Path $tempDir) {
        Remove-Item -Recurse -Force $tempDir
    }
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

    # Copy essential files to temp directory
    Write-Host "Copying essential files..." -ForegroundColor Blue
    Copy-Item -Path "index.html" -Destination "$tempDir\" -Force
    Copy-Item -Path ".nojekyll" -Destination "$tempDir\" -Force
    
    # Copy assets directory if it exists
    if (Test-Path "assets") {
        Copy-Item -Path "assets" -Destination "$tempDir\" -Recurse -Force
    }

    # Copy other static files that might be needed
    foreach ($dir in @("images", "gatherings", "public", "img", "static", "fonts", "favicon.ico")) {
        if (Test-Path $dir) {
            Write-Host "Copying $dir..." -ForegroundColor Blue
            Copy-Item -Path $dir -Destination "$tempDir\" -Recurse -Force
        }
    }

    # Download the gh-pages README from the main branch
    Write-Host "Creating README.md for gh-pages..." -ForegroundColor Blue
    $readmePath = "$tempDir\README.md"
    
    # Copy the specialized README or use a basic one
    if (Test-Path "d:\Github_personal\GHPAGES_README.md") {
        Copy-Item -Path "d:\Github_personal\GHPAGES_README.md" -Destination $readmePath -Force
    } else {
        @"
# Elmentor Landing Page (Deployed Site)

This branch contains the deployed version of the Elmentor Landing Page website that is served via GitHub Pages.

## Important Notes

- This is the **deployment branch** containing only built files
- Do NOT make direct changes to files in this branch
- Do NOT merge this branch into the `main` branch
- All development should occur on the `main` branch
"@ | Out-File -FilePath $readmePath -Encoding utf8
    }

    # Clean gh-pages branch - remove all files except .git
    Write-Host "Cleaning gh-pages branch..." -ForegroundColor Blue
    Get-ChildItem -Path "." -Exclude @(".git", ".temp") | Remove-Item -Recurse -Force

    # Copy files back from temp directory
    Write-Host "Restoring essential files..." -ForegroundColor Blue
    Copy-Item -Path "$tempDir\*" -Destination "." -Recurse -Force

    # Stage the changes
    Write-Host "Staging changes..." -ForegroundColor Blue
    git add -A

    # Commit the changes
    Write-Host "Committing changes..." -ForegroundColor Blue
    git commit -m "Clean up gh-pages branch structure to DevOps Visions standards"

    Write-Host "GH-Pages branch structure has been cleaned up according to DevOps Visions standards." -ForegroundColor Green
    Write-Host "To push these changes to origin, run: git push origin gh-pages" -ForegroundColor Yellow
    
} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
} finally {
    # Return to original branch
    Write-Host "Returning to $currentBranch branch..." -ForegroundColor Blue
    git checkout $currentBranch
}
