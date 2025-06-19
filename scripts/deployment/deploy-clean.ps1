#!/usr/bin/env pwsh
# Enhanced GitHub Pages deployment script for Elmentor Landing Page
# This script includes checks to avoid common deployment issues

# Abort on errors
$ErrorActionPreference = "Stop"

# Make sure we're in the right directory
Set-Location -Path $PSScriptRoot

# Clear the console
Clear-Host

Write-Host "===== ELMENTOR LANDING PAGE - CLEAN DEPLOYMENT SCRIPT =====" -ForegroundColor Cyan
Write-Host ""

# Function to perform pre-deployment checks
function Perform-PreDeploymentChecks {
    $issues = 0
    
    # Check 1: Ensure all required NPM dependencies are installed
    Write-Host "Checking NPM dependencies..." -ForegroundColor Yellow
    if (-not (Test-Path -Path ".\node_modules")) {
        Write-Host "  [WARNING] node_modules not found. Installing dependencies..." -ForegroundColor Yellow
        npm install
        if (-not $?) {
            Write-Host "  [ERROR] Failed to install dependencies!" -ForegroundColor Red
            $issues++
        } else {
            Write-Host "  [OK] Dependencies installed successfully." -ForegroundColor Green
        }
    } else {
        Write-Host "  [OK] node_modules found." -ForegroundColor Green
    }

    # Check 2: Ensure we have the right base path in vite.config.ts
    Write-Host "Checking Vite configuration..." -ForegroundColor Yellow
    $viteConfig = Get-Content -Path ".\vite.config.ts" -Raw
    if ($viteConfig -notmatch "base: '\/elmentor-landing-page-clean\/'") {
        Write-Host "  [ERROR] Incorrect base path in vite.config.ts!" -ForegroundColor Red
        Write-Host "          Should be set to '/elmentor-landing-page-clean/'" -ForegroundColor Red
        $issues++
    } else {
        Write-Host "  [OK] Base path correctly configured." -ForegroundColor Green
    }
    
    # Check 3: Check for missing asset files
    Write-Host "Checking critical assets..." -ForegroundColor Yellow
    $criticalAssets = @(
        ".\src\assets\images\elmentor-logo.png", 
        ".\public\assets\circles\elmentor-circles.png",
        ".\src\assets\images\founder\mohamed-radwan.png"
    )
    
    foreach ($asset in $criticalAssets) {
        if (-not (Test-Path -Path $asset)) {
            Write-Host "  [ERROR] Missing critical asset: $asset" -ForegroundColor Red
            $issues++
        } else {
            Write-Host "  [OK] Found $asset" -ForegroundColor Green
        }
    }
    
    # Check 4: Verify React Router DOM is installed (for Arabic version)
    Write-Host "Checking React Router DOM (for Arabic version)..." -ForegroundColor Yellow
    $packageJson = Get-Content -Path ".\package.json" -Raw | ConvertFrom-Json
    if (-not ($packageJson.dependencies.'react-router-dom')) {
        Write-Host "  [WARNING] react-router-dom not found in dependencies. Installing..." -ForegroundColor Yellow
        npm install react-router-dom --save
        if (-not $?) {
            Write-Host "  [ERROR] Failed to install react-router-dom!" -ForegroundColor Red
            $issues++
        } else {
            Write-Host "  [OK] react-router-dom installed successfully." -ForegroundColor Green
        }
    } else {
        Write-Host "  [OK] react-router-dom is installed." -ForegroundColor Green
    }

    # Check 5: Verify no TypeScript errors
    Write-Host "Checking for TypeScript errors..." -ForegroundColor Yellow
    npx tsc --noEmit
    if (-not $?) {
        Write-Host "  [WARNING] TypeScript errors found. These may affect the build." -ForegroundColor Yellow
    } else {
        Write-Host "  [OK] No TypeScript errors found." -ForegroundColor Green
    }

    return $issues
}

# Function to clean build artifacts
function Clean-BuildArtifacts {
    Write-Host "Cleaning previous build artifacts..." -ForegroundColor Yellow
    
    # Remove dist directory if it exists
    if (Test-Path -Path ".\dist") {
        Remove-Item -Path ".\dist" -Recurse -Force
        Write-Host "  [OK] Removed previous dist directory." -ForegroundColor Green
    }
    
    # Optional: Clean node_modules and reinstall for a truly fresh build
    $cleanDeps = $false  # Set to $true to force clean install of dependencies
    if ($cleanDeps) {
        if (Test-Path -Path ".\node_modules") {
            Write-Host "  Removing node_modules for clean install..." -ForegroundColor Yellow
            Remove-Item -Path ".\node_modules" -Recurse -Force
            npm install
            Write-Host "  [OK] Dependencies reinstalled." -ForegroundColor Green
        }
    }
}

# Function to build the project
function Build-Project {
    Write-Host "Building project..." -ForegroundColor Yellow
    npm run build
    if (-not $?) {
        Write-Host "  [ERROR] Build failed! Aborting deployment." -ForegroundColor Red
        return $false
    }
    Write-Host "  [OK] Build completed successfully." -ForegroundColor Green
    return $true
}

# Function to deploy to GitHub Pages
function Deploy-ToGitHubPages {
    # Navigate into the build output directory
    Set-Location -Path ".\dist"

    Write-Host "Preparing GitHub Pages deployment..." -ForegroundColor Yellow

    # Create or update .nojekyll file (prevents Jekyll processing)
    New-Item -ItemType File -Path ".nojekyll" -Force | Out-Null
    Write-Host "  [OK] Created .nojekyll file." -ForegroundColor Green

    # If you are deploying to a custom domain
    # Set-Content -Path "CNAME" -Value "www.your-domain.com"

    # Initialize Git repo
    Write-Host "Initializing Git repository..." -ForegroundColor Yellow
    git init
    git add -A

    # Commit changes
    Write-Host "Committing changes..." -ForegroundColor Yellow
    git commit -m "Deploy to GitHub Pages - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

    # Get GitHub username from git config
    $githubUsername = git config user.github
    if (-not $githubUsername) {
        # Try to get it from remote URL
        $remoteUrl = git config --get remote.origin.url
        if ($remoteUrl -match "github.com[:/]([^/]+)/") {
            $githubUsername = $Matches[1]
        } else {
            $githubUsername = "aymanaboghonim" # Default fallback
        }
    }
    
    # Force push to the gh-pages branch
    Write-Host "Pushing to GitHub Pages..." -ForegroundColor Yellow
    $repoUrl = "git@github.com:$githubUsername/elmentor-landing-page-clean.git"
    git push -f $repoUrl main:gh-pages
    
    if (-not $?) {
        Write-Host "  [ERROR] Failed to push to GitHub Pages!" -ForegroundColor Red
        Write-Host "  Attempting alternative deployment method..." -ForegroundColor Yellow
        
        # Try with HTTPS URL instead
        $repoUrl = "https://github.com/$githubUsername/elmentor-landing-page-clean.git"
        git push -f $repoUrl main:gh-pages
        
        if (-not $?) {
            Write-Host "  [ERROR] Both deployment methods failed!" -ForegroundColor Red
            return $false
        }
    }
    
    # Return to the project root
    Set-Location -Path $PSScriptRoot
    
    Write-Host "  [OK] Deployed successfully to GitHub Pages." -ForegroundColor Green
    return $true
}

# Main execution
Write-Host "Starting deployment process..." -ForegroundColor Cyan

# Step 1: Pre-deployment checks
Write-Host "[Step 1/4] Running pre-deployment checks..." -ForegroundColor Magenta
$issuesFound = Perform-PreDeploymentChecks
if ($issuesFound -gt 0) {
    Write-Host "Found $issuesFound issues that may affect deployment." -ForegroundColor Yellow
    $continue = Read-Host "Do you want to continue with deployment? (y/n)"
    if ($continue -ne "y") {
        Write-Host "Deployment aborted by user." -ForegroundColor Yellow
        exit 0
    }
}

# Step 2: Clean build artifacts
Write-Host "[Step 2/4] Cleaning build artifacts..." -ForegroundColor Magenta
Clean-BuildArtifacts

# Step 3: Build the project
Write-Host "[Step 3/4] Building the project..." -ForegroundColor Magenta
$buildSuccess = Build-Project
if (-not $buildSuccess) {
    Write-Host "Deployment failed at build stage." -ForegroundColor Red
    exit 1
}

# Step 4: Deploy to GitHub Pages
Write-Host "[Step 4/4] Deploying to GitHub Pages..." -ForegroundColor Magenta
$deploySuccess = Deploy-ToGitHubPages
if (-not $deploySuccess) {
    Write-Host "Deployment to GitHub Pages failed." -ForegroundColor Red
    exit 1
}

# Deployment completed
$githubUsername = git config user.github
if (-not $githubUsername) {
    $remoteUrl = git config --get remote.origin.url
    if ($remoteUrl -match "github.com[:/]([^/]+)/") {
        $githubUsername = $Matches[1]
    } else {
        $githubUsername = "aymanaboghonim" # Default fallback
    }
}

Write-Host ""
Write-Host "===== DEPLOYMENT COMPLETED SUCCESSFULLY! =====" -ForegroundColor Green
Write-Host ""
Write-Host "Your site should be available at:" -ForegroundColor Cyan
Write-Host "https://$githubUsername.github.io/elmentor-landing-page-clean/" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host ""
Write-Host "Please allow a few minutes for GitHub Pages to process the deployment." -ForegroundColor Yellow
