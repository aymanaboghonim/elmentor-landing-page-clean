#!/bin/bash
# Fully automated GitHub Pages deployment script
# No user input required

# Configuration (change these values)
GITHUB_USERNAME="elmentor-user"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"  # Set this as environment variable or update here
REPO_NAME="elmentor-landing-page-clean"
COMMIT_MESSAGE="Automated deployment"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log function
log() {
  local level=$1
  local message=$2
  local color=$NC
  
  case $level in
    "INFO") color=$BLUE ;;
    "SUCCESS") color=$GREEN ;;
    "WARNING") color=$YELLOW ;;
    "ERROR") color=$RED ;;
  esac
  
  echo -e "${color}[$level] $message${NC}"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> deploy.log
}

# Change to project directory
cd "$(dirname "$0")" || { log "ERROR" "Could not change to script directory"; exit 1; }
log "INFO" "Starting automated deployment process"

# Install required tools if not present
if ! command -v git &> /dev/null; then
    log "ERROR" "Git is not installed. Please install Git first."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    log "ERROR" "NPM is not installed. Please install Node.js first."
    exit 1
fi

# Configure Git if needed
if [[ -z "$(git config --global user.name)" ]]; then
    git config --global user.name "GitHub Actions"
    log "INFO" "Set default Git user name"
fi

if [[ -z "$(git config --global user.email)" ]]; then
    git config --global user.email "github-actions@github.com"
    log "INFO" "Set default Git user email"
fi

# Create GitHub repository using API
log "INFO" "Creating or checking GitHub repository: $REPO_NAME"
if [[ -z "$GITHUB_TOKEN" ]]; then
    log "WARNING" "GITHUB_TOKEN not set, skipping repository creation"
else
    # Check if repo exists
    http_code=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_USERNAME/$REPO_NAME")
    
    if [[ "$http_code" -eq 404 ]]; then
        # Create repository
        curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user/repos -d "{\"name\":\"$REPO_NAME\",\"description\":\"Elmentor Landing Page Clean Implementation\",\"private\":false}" > /dev/null
        log "SUCCESS" "Created repository: $GITHUB_USERNAME/$REPO_NAME"
    elif [[ "$http_code" -eq 200 ]]; then
        log "INFO" "Repository already exists: $GITHUB_USERNAME/$REPO_NAME"
    else
        log "WARNING" "Unexpected HTTP response: $http_code, proceeding anyway"
    fi
fi

# Initialize git if needed
if [[ ! -d .git ]]; then
    git init
    log "INFO" "Initialized Git repository"
fi

# Setup remote
git_remote=$(git remote)
if [[ "$git_remote" == *"origin"* ]]; then
    git remote set-url origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    log "INFO" "Updated remote URL"
else
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    log "INFO" "Added remote origin"
fi

# Update configuration files with correct GitHub username
log "INFO" "Updating configuration files with username: $GITHUB_USERNAME"

# Update files with either sed (Linux/macOS) or PowerShell (Windows)
if command -v sed &> /dev/null; then
    # Using sed (Linux/macOS)
    find . -type f -name "*.md" -o -name "*.ps1" -o -name "*.bat" -o -name "*.ts" | xargs sed -i "s/yourusername/$GITHUB_USERNAME/g; s/elmentor/$GITHUB_USERNAME/g"
else
    # Using PowerShell (Windows)
    powershell -Command "Get-ChildItem -Recurse -Include *.md,*.ps1,*.bat,*.ts | ForEach-Object { (Get-Content \$_.FullName) -replace 'yourusername', '$GITHUB_USERNAME' -replace 'elmentor', '$GITHUB_USERNAME' | Set-Content \$_.FullName }"
fi

log "INFO" "Updated GitHub username in configuration files"

# Update vite.config.ts for GitHub Pages
log "INFO" "Updating vite.config.ts for GitHub Pages"
if command -v sed &> /dev/null; then
    # Using sed (Linux/macOS)
    sed -i "s|base: ['\"]\([^'\"]*\)['\"]|base: '/$REPO_NAME/'|g" vite.config.ts
else
    # Using PowerShell (Windows)
    powershell -Command "(Get-Content vite.config.ts) -replace \"base: ['\\\"](.*)['\\\"]\" , \"base: '/$REPO_NAME/'\" | Set-Content vite.config.ts"
fi

# Install dependencies
log "INFO" "Installing dependencies"
npm install

# Build the project
log "INFO" "Building project"
npm run build
if [[ $? -ne 0 ]]; then
    log "ERROR" "Build failed"
    exit 1
fi
log "SUCCESS" "Build completed successfully"

# Deploy to GitHub Pages
log "INFO" "Deploying to GitHub Pages"

# Navigate to build directory
cd dist || { log "ERROR" "dist directory not found"; exit 1; }

# Create .nojekyll file
touch .nojekyll
log "INFO" "Created .nojekyll file"

# Initialize Git
git init
git add -A
git commit -m "$COMMIT_MESSAGE"

# Use token if available for authentication
if [[ -n "$GITHUB_TOKEN" ]]; then
    remote_url="https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git"
else
    remote_url="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
fi

# Push to gh-pages branch
git push -f "$remote_url" main:gh-pages

# Return to project root
cd ..

log "SUCCESS" "Deployment completed"
log "SUCCESS" "Site URL: https://$GITHUB_USERNAME.github.io/$REPO_NAME/"

# Create success marker file
echo "Deployment completed successfully at $(date)" > deployment_success.txt
echo "Site URL: https://$GITHUB_USERNAME.github.io/$REPO_NAME/" >> deployment_success.txt
