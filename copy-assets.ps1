# Copy Required Assets from Original Project
# Run this script from the elmentor-landing-page-clean directory

$originalPath = "d:\Github_personal\elmentor-landing-page"
$cleanPath = "d:\Github_personal\elmentor-landing-page-clean"

Write-Host "Copying required assets from original project..." -ForegroundColor Green

# Create directories if they don't exist
$publicPath = Join-Path $cleanPath "public"
$assetsImagesPath = Join-Path $cleanPath "src\assets\images"

# Copy elmentor-circles.png to public directory
$sourcePath = Join-Path $originalPath "public\elmentor-circles.png"
$destPath = Join-Path $publicPath "elmentor-circles.png"
if (Test-Path $sourcePath) {
    Copy-Item $sourcePath $destPath -Force
    Write-Host "✓ Copied elmentor-circles.png to public directory" -ForegroundColor Green
} else {
    Write-Host "✗ Source file not found: $sourcePath" -ForegroundColor Red
}

# Copy logo image
$sourcePath = Join-Path $originalPath "src\assets\images\elmentor-logo.png"
$destPath = Join-Path $assetsImagesPath "elmentor-logo.png"
if (Test-Path $sourcePath) {
    Copy-Item $sourcePath $destPath -Force
    Write-Host "✓ Copied elmentor-logo.png" -ForegroundColor Green
} else {
    Write-Host "✗ Source file not found: $sourcePath" -ForegroundColor Red
}

# Copy founder image
$sourcePath = Join-Path $originalPath "src\assets\images\mohamed-radwan.png"
$destPath = Join-Path $assetsImagesPath "mohamed-radwan.png"
if (Test-Path $sourcePath) {
    Copy-Item $sourcePath $destPath -Force
    Write-Host "✓ Copied mohamed-radwan.png" -ForegroundColor Green
} else {
    Write-Host "✗ Source file not found: $sourcePath" -ForegroundColor Red
}

# Copy DevOps Visions logos
$sourcePath = Join-Path $originalPath "src\assets\images\DevOps-Visions.png"
$destPath = Join-Path $assetsImagesPath "DevOps-Visions.png"
if (Test-Path $sourcePath) {
    Copy-Item $sourcePath $destPath -Force
    Write-Host "✓ Copied DevOps-Visions.png" -ForegroundColor Green
} else {
    Write-Host "✗ Source file not found: $sourcePath" -ForegroundColor Red
}

$sourcePath = Join-Path $originalPath "src\assets\images\DevOps-Visions_Horizontal_Green.png"
$destPath = Join-Path $assetsImagesPath "DevOps-Visions_Horizontal_Green.png"
if (Test-Path $sourcePath) {
    Copy-Item $sourcePath $destPath -Force
    Write-Host "✓ Copied DevOps-Visions_Horizontal_Green.png" -ForegroundColor Green
} else {
    Write-Host "✗ Source file not found: $sourcePath" -ForegroundColor Red
}

Write-Host "`nAsset copying completed!" -ForegroundColor Cyan
Write-Host "You can now run 'npm run dev' to see the website with all assets." -ForegroundColor Cyan
