#!/usr/bin/env pwsh
# Script to download placeholder gathering images

$gatherings = @(
    @{
        "name" = "tokyo-2022";
        "url" = "https://source.unsplash.com/random/800x600/?tokyo,japan,conference";
    },
    @{
        "name" = "cairo-2023";
        "url" = "https://source.unsplash.com/random/800x600/?cairo,egypt,conference";
    },
    @{
        "name" = "seattle-2023";
        "url" = "https://source.unsplash.com/random/800x600/?seattle,usa,conference";
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
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $gathering.url -OutFile $outputPath
        Write-Host "Successfully downloaded $($gathering.name) image" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download $($gathering.name) image: $_" -ForegroundColor Red
    }
}

Write-Host "All gathering images have been processed" -ForegroundColor Green
