# Deploy Landing Page with Navigation Fixes

$originalLocation = Get-Location
$repositoryPath = "D:\Github_personal\elmentor-landing-page-clean"
$tempDeployPath = "D:\Github_personal\temp-deploy-elmentor"
$deployBranch = "gh-pages"

Write-Host "🚀 Starting deployment process with navigation fixes..." -ForegroundColor Cyan

# Navigate to the repository directory
try {
    Set-Location -Path $repositoryPath
    
    # Build the project
    Write-Host "🔨 Building the project..." -ForegroundColor Yellow
    npm run build
    
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed with exit code $LASTEXITCODE"
    }
    
    Write-Host "✅ Build successful!" -ForegroundColor Green
    
    # Prepare temporary deployment directory
    if (Test-Path -Path $tempDeployPath) {
        Write-Host "🧹 Cleaning up previous temp deployment directory..." -ForegroundColor Yellow
        Remove-Item -Path $tempDeployPath -Recurse -Force
    }
    
    New-Item -Path $tempDeployPath -ItemType Directory | Out-Null
    
    # Copy build files to the temporary directory
    Write-Host "📦 Copying build files to temporary directory..." -ForegroundColor Yellow
    Copy-Item -Path "$repositoryPath\dist\*" -Destination $tempDeployPath -Recurse
    
    # Initialize git in the temporary directory
    Set-Location -Path $tempDeployPath
    git init
    
    # Configure git
    git config user.name "Deployment Script"
    git config user.email "deployment@example.com"
    
    # Add all files
    git add .
    
    # Commit
    git commit -m "Deploy landing page with navigation fixes"
    
    # Add remote
    git remote add origin git@github.com:aymanaboghonim/elmentor-landing-page-clean.git
    
    # Push to gh-pages branch, force overwrite
    Write-Host "🚀 Pushing to $deployBranch branch..." -ForegroundColor Yellow
    git push -f origin master:$deployBranch
    
    if ($LASTEXITCODE -ne 0) {
        throw "Git push failed with exit code $LASTEXITCODE"
    }
    
    Write-Host "✅ Deployment complete! Your site should be available at:" -ForegroundColor Green
    Write-Host "https://aymanaboghonim.github.io/elmentor-landing-page-clean/" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Return to original location
    Set-Location -Path $originalLocation
    
    # Clean up temp directory
    if (Test-Path -Path $tempDeployPath) {
        Write-Host "🧹 Cleaning up temporary deployment directory..." -ForegroundColor Yellow
        Remove-Item -Path $tempDeployPath -Recurse -Force
    }
}
