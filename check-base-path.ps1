# Check Base Path in Built Index.html

Write-Host "🔍 Checking index.html for correct base path configuration..." -ForegroundColor Cyan

# Function to verify base path in index.html
function Test-BasePath {
    param (
        [string]$indexHtmlPath
    )
    
    if (-not (Test-Path -Path $indexHtmlPath)) {
        Write-Host "❌ Error: $indexHtmlPath not found!" -ForegroundColor Red
        return $false
    }
    
    $content = Get-Content -Path $indexHtmlPath -Raw
    
    # Check for the correct base path in asset references
    $hasCorrectBasePath = $content -match "/elmentor-landing-page-clean/assets/"
    
    if ($hasCorrectBasePath) {
        Write-Host "✅ Base path correctly configured in $indexHtmlPath" -ForegroundColor Green
        Write-Host "   Found references to '/elmentor-landing-page-clean/assets/'" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ Base path may not be correctly configured in $indexHtmlPath" -ForegroundColor Red
        Write-Host "   Could not find references to '/elmentor-landing-page-clean/assets/'" -ForegroundColor Red
        return $false
    }
}

# Check if we need to build first
if (-not (Test-Path -Path ".\dist\index.html")) {
    $buildFirst = Read-Host -Prompt "dist/index.html not found. Build the project first? (y/n)"
    
    if ($buildFirst -eq "y") {
        Write-Host "🔨 Building project..." -ForegroundColor Yellow
        npm run build
        
        if (-not (Test-Path -Path ".\dist\index.html")) {
            Write-Host "❌ Build failed or did not produce index.html!" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ Cannot check index.html: File not found!" -ForegroundColor Red
        exit 1
    }
}

# Test the index.html file
Test-BasePath -indexHtmlPath ".\dist\index.html"

Write-Host "`n💡 If the base path is incorrect, make sure:" -ForegroundColor Yellow
Write-Host "   1. vite.config.ts has the correct base path setting" -ForegroundColor White
Write-Host "   2. You're using HashRouter correctly in main.tsx" -ForegroundColor White
Write-Host "   3. Asset references use the correct relative paths" -ForegroundColor White
