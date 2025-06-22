# Move to Temp Directory Script
# Purpose: Moves files to the .temp directory which is ignored by Git

param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,
    
    [Parameter(Mandatory=$false)]
    [string]$DestinationName
)

# Create .temp directory if it doesn't exist
if (-not (Test-Path .temp)) {
    New-Item -Path .temp -ItemType Directory | Out-Null
    Write-Output "Created .temp directory"
}

# If destination name not provided, use the source name
if (-not $DestinationName) {
    $DestinationName = (Get-Item $SourcePath).Name
}

# Full destination path
$DestinationPath = Join-Path -Path ".temp" -ChildPath $DestinationName

# Copy the file/folder to .temp
Copy-Item -Path $SourcePath -Destination $DestinationPath -Recurse -Force
Write-Output "Copied '$SourcePath' to '$DestinationPath'"
