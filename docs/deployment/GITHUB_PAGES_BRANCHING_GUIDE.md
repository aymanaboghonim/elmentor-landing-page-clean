# GitHub Pages & Branching Guide

This guide explains the branch structure in this repository and how GitHub Pages deployment works.

## Branch Structure

- **`master`**: Main development branch containing the source code
- **`gh-pages`**: Deployment branch containing the built application (generated output only)

## GitHub Pages Deployment

This project deploys to GitHub Pages using the `gh-pages` branch, which contains only the production build output from the application.

### Important Notes

1. **Never merge the `gh-pages` branch into `master`**
   - The `gh-pages` branch contains only build output and should never be merged into source branches
   - GitHub may suggest a "Compare & pull request" for `gh-pages` → `master`, but these should always be ignored

2. **Default Branch**
   - The repository uses `master` as the default branch
   - Changing the default branch will not affect GitHub Pages, as it's configured to deploy from the `gh-pages` branch

3. **Deployment Process**
   - The deployment process builds the application and pushes the result to the `gh-pages` branch
   - This is handled by the scripts in the `/scripts` directory (`deploy.ps1`, `sync-gh-pages.ps1`, etc.)

## Automation for Branch Protection

The repository includes automation to help prevent accidental merges:

1. Pull requests from `gh-pages` get automatically labeled with "do-not-merge"
2. A `.mergeignore` file lists branches that should not be merged into other branches
3. The PR validation workflow checks for and warns about prohibited branch merges

## Manual Branch Management

If you need to manually change settings related to branches:

1. **Change Default Branch**
   - Go to repository Settings → Branches
   - Click the switch icon (↓↑) next to "Default branch"
   - Select your desired branch and confirm

2. **Branch Protection**
   - Go to repository Settings → Branches → Branch protection rules
   - Add rules to prevent direct pushes or require reviews
