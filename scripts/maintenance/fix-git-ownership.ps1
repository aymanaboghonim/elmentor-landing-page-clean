#!/usr/bin/env pwsh
# Script to fix Git "dubious ownership" error during deployment

# Function for logging
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path "git-fix.log" -Value $logMessage
    
    # Also output to console with color
    $color = switch ($Level) {
        "INFO" { "White" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        "SUCCESS" { "Green" }
        default { "White" }
    }
    
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $color
    Write-Output $logMessage
    $host.UI.RawUI.ForegroundColor = $fc
}

# Make sure we're in the right directory
Set-Location -Path $PSScriptRoot
Write-Log -Message "Working in directory: $PSScriptRoot" -Level "INFO"

# Check for Git
try {
    $gitVersion = git --version
    Write-Log -Message "Git version: $gitVersion" -Level "INFO"
}
catch {
    Write-Log -Message "Git is not installed" -Level "ERROR"
    exit 1
}

# Get the absolute path to the repository and dist directory
$repoPath = (Get-Location).Path
$distPath = Join-Path -Path $repoPath -ChildPath "dist"

# Check if dist directory exists
if (Test-Path -Path $distPath) {
    Write-Log -Message "Adding dist directory to Git safe.directory" -Level "INFO"
    
    # Add both the repository and dist directory to Git safe.directory
    git config --global --add safe.directory $repoPath
    git config --global --add safe.directory $distPath
    
    Write-Log -Message "Repository path added to safe.directory: $repoPath" -Level "SUCCESS"
    Write-Log -Message "Dist path added to safe.directory: $distPath" -Level "SUCCESS"
    
    # Verify the configuration
    $safeDirectories = git config --global --get-all safe.directory
    Write-Log -Message "Current safe.directory configuration:" -Level "INFO"
    $safeDirectories | ForEach-Object {
        Write-Log -Message "  - $_" -Level "INFO"
    }
    
    Write-Log -Message "Git ownership issue fixed. You can now run the deployment script." -Level "SUCCESS"
} else {
    Write-Log -Message "Dist directory not found at: $distPath" -Level "WARNING"
    Write-Log -Message "Run 'npm run build' first to create the dist directory" -Level "WARNING"
    
    # Still add the repository path to safe.directory
    git config --global --add safe.directory $repoPath
    Write-Log -Message "Repository path added to safe.directory: $repoPath" -Level "SUCCESS"
    
    Write-Log -Message "Partial fix applied. Build the project and run this script again." -Level "WARNING"
}

# Instructions for the user
Write-Log -Message "Next steps:" -Level "INFO"
Write-Log -Message "1. Run 'npm run build' (if not already done)" -Level "INFO"
Write-Log -Message "2. Run the deployment script: .\gh-auto-deploy.ps1" -Level "INFO"
