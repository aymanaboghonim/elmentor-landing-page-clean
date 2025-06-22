# GitHub Pages Deployment Script
# Purpose: Builds and deploys the website to GitHub Pages

# Load GitHub username from config
$githubUsername = Get-Content -Path "github-config.txt" -TotalCount 1

# Build the site
npm run build

# Deploy to GitHub Pages
npx gh-pages -d dist -r https://github.com/$githubUsername/elmentor-landing-page-clean.git

Write-Output "Deployment complete! Your site should be live shortly at https://$githubUsername.github.io/elmentor-landing-page-clean/"
