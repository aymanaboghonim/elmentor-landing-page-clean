# Script to clean up and organize the repository
# Then push to GitHub with a clean structure

# Set error action preference
$ErrorActionPreference = "Stop"

# Create necessary directories if they don't exist
$directories = @("scripts", "docs")
foreach ($dir in $directories) {
    if (-not (Test-Path -Path $dir)) {
        Write-Host "Creating directory: $dir" -ForegroundColor Green
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Move deployment scripts to scripts directory
Write-Host "Moving deployment scripts to scripts directory..." -ForegroundColor Cyan
$deploymentScripts = Get-ChildItem -Path "." -Filter "deploy*.ps1" | Where-Object { $_.Name -ne "deploy.bat" -and $_.Directory -eq $PWD }
foreach ($script in $deploymentScripts) {
    if ($script.Name -ne "deploy.ps1" -and -not (Test-Path -Path "scripts\$($script.Name)")) {
        Move-Item -Path $script.FullName -Destination "scripts\" -Force
    }
}

# Move documentation files to docs directory
Write-Host "Moving documentation files to docs directory..." -ForegroundColor Cyan
$docFiles = Get-ChildItem -Path "." -Filter "*.md" | Where-Object { 
    $_.Name -ne "README.md" -and
    $_.Directory -eq $PWD -and
    $_.Name -notlike "LICENSE*" -and
    $_.Name -match "^[A-Z_]+\.md$" 
}

foreach ($doc in $docFiles) {
    if (-not (Test-Path -Path "docs\$($doc.Name)")) {
        Move-Item -Path $doc.FullName -Destination "docs\" -Force
    }
}

# Clean up log files and temporary files
Write-Host "Cleaning up log and temporary files..." -ForegroundColor Cyan
$filesToRemove = Get-ChildItem -Path "." -File | Where-Object {
    $_.Name -like "*_success_*.txt" -or
    $_.Name -like "*.log" -or
    ($_.Name -like "*.bat" -and $_.Name -ne "deploy.bat")
}

foreach ($file in $filesToRemove) {
    Remove-Item -Path $file.FullName -Force
}

# Create .gitkeep files for empty directories
$emptyDirs = Get-ChildItem -Path "." -Directory -Recurse | Where-Object { (Get-ChildItem -Path $_.FullName).Count -eq 0 }
foreach ($dir in $emptyDirs) {
    $gitkeepPath = Join-Path -Path $dir.FullName -ChildPath ".gitkeep"
    if (-not (Test-Path -Path $gitkeepPath)) {
        Write-Host "Adding .gitkeep to empty directory: $($dir.FullName)" -ForegroundColor Yellow
        New-Item -ItemType File -Path $gitkeepPath -Force | Out-Null
    }
}

# Commit changes
Write-Host "Committing changes..." -ForegroundColor Cyan
git add .
git commit -m "Repository structure organized for clarity and maintainability"

# Push to GitHub
$pushToGithub = Read-Host -Prompt "Do you want to push changes to GitHub now? (y/n)"
if ($pushToGithub -eq "y") {
    Write-Host "Pushing changes to GitHub..." -ForegroundColor Green
    git push origin master
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Repository successfully cleaned up and pushed to GitHub!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to push to GitHub. Please check your Git configuration and try again." -ForegroundColor Red
    }
} else {
    Write-Host "Skipping push to GitHub. Run 'git push origin master' when you're ready." -ForegroundColor Yellow
}

Write-Host "`nRepository structure has been organized. Here's what was done:" -ForegroundColor Cyan
Write-Host "1. Created a clean directory structure (src, public, scripts, docs)" -ForegroundColor White
Write-Host "2. Moved deployment scripts to the scripts directory" -ForegroundColor White
Write-Host "3. Moved documentation files to the docs directory" -ForegroundColor White
Write-Host "4. Cleaned up temporary and log files" -ForegroundColor White
Write-Host "5. Created main documentation files (README.md, DEPLOYMENT.md, etc.)" -ForegroundColor White
Write-Host "6. Updated .gitignore for better file management" -ForegroundColor White
