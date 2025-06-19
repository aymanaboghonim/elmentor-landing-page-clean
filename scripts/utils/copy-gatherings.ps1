#!/usr/bin/env pwsh
# Script to copy proper gathering images

$gatherings = @(
    @{
        "name" = "tokyo-2022";
        "url" = "https://raw.githubusercontent.com/DevOpsVisions/elmentor-landing/main/src/assets/community/tokyo.jpg";
    },
    @{
        "name" = "cairo-2023";
        "url" = "https://raw.githubusercontent.com/DevOpsVisions/elmentor-landing/main/src/assets/community/cairo.jpg";
    },
    @{
        "name" = "seattle-2023";
        "url" = "https://raw.githubusercontent.com/DevOpsVisions/elmentor-landing/main/src/assets/community/seattle.jpg";
    }
)

$destinationFolder = ".\public\gatherings"

if (-not (Test-Path $destinationFolder)) {
    New-Item -Path $destinationFolder -ItemType Directory -Force
}

foreach ($gathering in $gatherings) {
    $outputPath = Join-Path -Path $destinationFolder -ChildPath "$($gathering.name).jpg"
    Write-Host "Downloading $($gathering.name) image from $($gathering.url) to $outputPath"
    
    try {
        Invoke-WebRequest -Uri $gathering.url -OutFile $outputPath
        Write-Host "Successfully downloaded $($gathering.name) image" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download $($gathering.name) image: $_" -ForegroundColor Red
    }
}

Write-Host "All gathering images have been processed" -ForegroundColor Green
