# Simple PR merge script

Write-Host "🔄 Simple PR Merge Script" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Default values
$Branch = "feature/docs-organization" 
$TargetBranch = "master"

Write-Host "Will merge $Branch into $TargetBranch" -ForegroundColor Yellow
Write-Host ""

# Check for clean working directory
$status = git status --porcelain
if ($status.Length -ne 0) {
    Write-Host "❌ Working directory has unstaged changes. Please commit or stash your changes first." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Working directory clean" -ForegroundColor Green

# Fetch latest changes
Write-Host "🔄 Fetching latest changes from remote..." -ForegroundColor Cyan
git fetch origin
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to fetch from remote." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Fetched latest changes" -ForegroundColor Green

# Switch to target branch
Write-Host "🔄 Switching to target branch $TargetBranch..." -ForegroundColor Cyan
git checkout $TargetBranch
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to switch to target branch." -ForegroundColor Red
    exit 1
}

# Pull latest changes to target branch
Write-Host "🔄 Pulling latest changes to $TargetBranch..." -ForegroundColor Cyan
git pull origin $TargetBranch
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to pull latest changes to target branch." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Target branch updated" -ForegroundColor Green

# Merge
Write-Host "🔄 Merging $Branch into $TargetBranch..." -ForegroundColor Cyan
git merge origin/$Branch
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Merge conflicts detected. Please resolve them manually." -ForegroundColor Red
    exit 1
}

# Push changes
Write-Host "🔄 Pushing changes to remote..." -ForegroundColor Cyan
git push origin $TargetBranch
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to push changes." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Successfully merged $Branch into $TargetBranch and pushed to remote!" -ForegroundColor Green

# Delete the feature branch if it's been merged
$deleteBranch = Read-Host "Do you want to delete the $Branch branch locally and remotely? (y/n)"
if ($deleteBranch -eq "y") {
    Write-Host "🗑️ Deleting branch $Branch..." -ForegroundColor Cyan
    git branch -d $Branch
    git push origin --delete $Branch
    Write-Host "✅ Branch deleted" -ForegroundColor Green
}

Write-Host "`n🎉 Merge process completed successfully!" -ForegroundColor Green
