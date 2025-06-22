# Direct GitHub Pages Deployment Script
# Purpose: Deploys directly to GitHub Pages without running build step (for quick fixes)

# Load GitHub username from config
$githubUsername = Get-Content -Path "github-config.txt" -TotalCount 1

# Deploy existing dist directory to GitHub Pages
npx gh-pages -d dist -r https://github.com/$githubUsername/elmentor-landing-page-clean.git

Write-Output "Direct deployment complete! Your site should be live shortly at https://$githubUsername.github.io/elmentor-landing-page-clean/"
