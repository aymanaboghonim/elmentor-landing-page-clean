# Automated PR merge script with conflict avoidance
# This script safely merges pull requests with automatic conflict resolution strategies

param (
    [string]$Branch = "feature/docs-organization",  # Default branch to merge
    [string]$TargetBranch = "master",               # Default target branch
    [switch]$AutoResolve = $false,                  # Whether to attempt auto-resolution of conflicts
    [switch]$Force = $false,                        # Whether to force push (use with caution)
    [switch]$SkipChecks = $false                    # Whether to skip pre-merge checks
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Display header
Write-Host "🔄 Automated PR Merge Tool" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Source: $Branch -> Target: $TargetBranch" -ForegroundColor White
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Function to check for unstaged changes
function Test-CleanWorkingDirectory {
    $status = git status --porcelain
    return $status.Length -eq 0
}

# Function to try auto-resolving conflicts
function Resolve-GitConflicts {
    # Get list of conflicted files
    $conflictedFiles = git diff --name-only --diff-filter=U
    
    if ($conflictedFiles.Count -eq 0) {
        Write-Host "No conflicts detected." -ForegroundColor Green
        return $true
    }
    
    Write-Host "Attempting to resolve conflicts in $($conflictedFiles.Count) files..." -ForegroundColor Yellow
    
    foreach ($file in $conflictedFiles) {
        # For documentation files, prefer the newer version
        if ($file -like "*.md") {
            Write-Host "  - Resolving documentation file: $file (using 'theirs' strategy)" -ForegroundColor Yellow
            git checkout --theirs $file
            git add $file
        }
        # For code files, we typically can't auto-resolve
        else {
            Write-Host "  - Cannot auto-resolve code file: $file - manual intervention needed" -ForegroundColor Red
            return $false
        }
    }
    
    return $true
}

# Check for clean working directory unless skipping checks
if (-not $SkipChecks) {
    Write-Host "🔍 Checking for clean working directory..." -ForegroundColor Cyan
    if (-not (Test-CleanWorkingDirectory)) {
        Write-Host "❌ Working directory has unstaged changes. Please commit or stash your changes first." -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Working directory clean" -ForegroundColor Green
}

# Fetch latest changes
Write-Host "🔄 Fetching latest changes from remote..." -ForegroundColor Cyan
git fetch origin
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to fetch from remote. Verify network connection and try again." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Fetched latest changes" -ForegroundColor Green

# Check if branches exist
Write-Host "🔍 Verifying branches..." -ForegroundColor Cyan
git show-ref --verify --quiet refs/remotes/origin/$Branch
$sourceBranchValid = $LASTEXITCODE -eq 0

git show-ref --verify --quiet refs/remotes/origin/$TargetBranch
$targetBranchValid = $LASTEXITCODE -eq 0

if (-not ($sourceBranchValid -and $targetBranchValid)) {
    Write-Host "❌ One or both branches don't exist. Please verify branch names." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Branches verified" -ForegroundColor Green

# Switch to target branch
Write-Host "🔄 Switching to target branch $TargetBranch..." -ForegroundColor Cyan
git checkout $TargetBranch
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to switch to target branch. Please resolve any local conflicts first." -ForegroundColor Red
    exit 1
}

# Pull latest changes to target branch
Write-Host "🔄 Pulling latest changes to $TargetBranch..." -ForegroundColor Cyan
git pull origin $TargetBranch
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to pull latest changes to target branch. Please resolve any conflicts manually." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Target branch updated" -ForegroundColor Green

# Try to merge
Write-Host "🔄 Attempting to merge $Branch into $TargetBranch..." -ForegroundColor Cyan
git merge origin/$Branch --no-commit

# Handle merge result
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Merge conflicts detected!" -ForegroundColor Yellow
    
    if ($AutoResolve) {
        $resolved = Resolve-GitConflicts
        if (-not $resolved) {
            Write-Host "❌ Could not auto-resolve all conflicts. Aborting merge." -ForegroundColor Red
            git merge --abort
            exit 1
        }
        Write-Host "✅ Conflicts auto-resolved" -ForegroundColor Green
    } else {
        Write-Host "❌ Merge conflicts detected. Aborting merge. Use -AutoResolve to attempt automatic resolution." -ForegroundColor Red
        git merge --abort
        exit 1
    }
}

# Commit the merge
Write-Host "🔄 Committing merge..." -ForegroundColor Cyan
git commit -m "Merge $Branch into $TargetBranch

Automated merge of PR from $Branch to $TargetBranch.
This merge was performed using the automated PR merge script."

# Push changes
Write-Host "🔄 Pushing changes to remote..." -ForegroundColor Cyan
if ($Force) {
    git push origin $TargetBranch --force
} else {
    git push origin $TargetBranch
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to push changes. Please try again or push manually." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Successfully merged $Branch into $TargetBranch and pushed to remote!" -ForegroundColor Green

# Optional: Delete the feature branch if it's been merged
$deleteBranch = Read-Host "Do you want to delete the $Branch branch locally and remotely? (y/n)"
if ($deleteBranch -eq "y") {
    Write-Host "🗑️ Deleting branch $Branch..." -ForegroundColor Cyan
    git branch -d $Branch
    git push origin --delete $Branch
    Write-Host "✅ Branch deleted" -ForegroundColor Green
}

Write-Host "`n🎉 Merge process completed successfully!" -ForegroundColor Green
