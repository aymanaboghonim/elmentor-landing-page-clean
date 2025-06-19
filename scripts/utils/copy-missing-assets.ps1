# Copy Missing Assets Script for Elmentor Landing Page
# This script copies missing assets from the original repo to the clean repo

# Ensure we're in the right directory
Set-Location -Path "d:\Github_personal\elmentor-landing-page-clean"

# Create necessary directories if they don't exist
$directories = @(
    ".\public\assets",
    ".\public\assets\images",
    ".\public\assets\logos",
    ".\public\assets\founder",
    ".\public\assets\community",
    ".\public\assets\circles",
    ".\src\assets\images\founder",
    ".\src\assets\images\community",
    ".\src\assets\images\gatherings"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        Write-Host "Creating directory: $dir"
        New-Item -Path $dir -ItemType Directory -Force
    }
}

# Source paths
$originalRepoPath = "d:\Github_personal\original-elmentor"
$originalImagesPath = "$originalRepoPath\src\assets\images"
$originalPublicPath = "$originalRepoPath\public"

# Copy logo assets
Write-Host "Copying logo assets..."
Copy-Item -Path "$originalImagesPath\elmentor-logo.png" -Destination ".\src\assets\images\elmentor-logo.png" -Force
Copy-Item -Path "$originalPublicPath\elmentor-logo.svg" -Destination ".\public\assets\logos\elmentor-logo.svg" -Force
Copy-Item -Path "$originalPublicPath\elmentor-logo.svg" -Destination ".\src\assets\images\elmentor-logo.svg" -Force

# Copy founder image
Write-Host "Copying founder image..."
Copy-Item -Path "$originalImagesPath\mohamed-radwan.png" -Destination ".\src\assets\images\founder\mohamed-radwan.png" -Force
Copy-Item -Path "$originalImagesPath\mohamed-radwan.png" -Destination ".\public\assets\founder\mohamed-radwan.png" -Force

# Copy circles images
Write-Host "Copying circles images..."
Copy-Item -Path "$originalPublicPath\elmentor-circles.png" -Destination ".\public\assets\circles\elmentor-circles.png" -Force
Copy-Item -Path "$originalPublicPath\elmentor-circles.svg" -Destination ".\public\assets\circles\elmentor-circles.svg" -Force
Copy-Item -Path "$originalPublicPath\elmentor-circles.png" -Destination ".\src\assets\images\circles-diagram.png" -Force
Copy-Item -Path "$originalPublicPath\elmentor-circles.svg" -Destination ".\src\assets\images\circles-diagram.svg" -Force

# Create symbolic links for public assets in case the path is referenced directly
Write-Host "Creating symbolic links for public assets..."
cmd /c mklink /d ".\public\gatherings" ".\public\assets\community\gatherings" 2>$null

Write-Host "Asset copy completed successfully!"
