# Elmentor/DevOps Visions Landing Page

A clean, maintainable implementation of the Elmentor/DevOps Visions landing page built with TypeScript, React, and modern web development best practices.

## Overview

This project is a faithful recreation of the Elmentor/DevOps Visions landing page, featuring:

- Clean, type-safe code with TypeScript and React
- Component-based architecture for maintainability
- Comprehensive design system with CSS variables
- Fully responsive design for all device sizes
- Accessibility features built-in
- Performance optimizations
- GitHub Pages deployment setup

## Live Demo

The landing page is deployed and available at: https://elmentor.github.io/elmentor-landing-page-clean/

(Note: Update the URL with your actual GitHub username after deployment)

## Getting Started

### Important Note on Assets and Build

The project currently uses SVG placeholders for certain assets that were not available in the original repository:
- Community gathering images (Tokyo, Cairo, Seattle)
- Some logo files

See `ASSET_ISSUE_RCA.md` for details on these placeholder assets.

There's also a TypeScript build issue in HeroSection.tsx. Use development mode for now (see `QUICK_FIX_GUIDE.md`).

### Prerequisites

- Node.js (v16.0.0 or higher)
- npm (v7.0.0 or higher)

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/elmentor-landing-page-clean.git
   cd elmentor-landing-page-clean
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Migrate assets (if not already done):
   - Follow instructions in [ASSET_MIGRATION_GUIDE.md](./ASSET_MIGRATION_GUIDE.md)
   - Or run one of the provided asset copy scripts

4. Start the development server:
   ```bash
   npm run dev
   ```

5. Open [http://localhost:3000](http://localhost:3000) to view the site in your browser.

## Project Structure

```
elmentor-landing-page-clean/
├── public/                      # Public static assets
│   ├── gatherings/              # Community gathering images
│   └── elmentor-circles.png     # Circles diagram
├── src/
│   ├── assets/                  # Project assets
│   │   └── images/              # Image assets
│   ├── components/              # React components
│   │   ├── sections/            # Page section components
│   │   └── ...                  # Reusable components
│   ├── styles/                  # CSS files
│   ├── utils/                   # Utility functions
│   ├── App.tsx                  # Main application component
│   └── main.tsx                 # Entry point
└── ... configuration files
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build locally
- `npm run typecheck` - Check TypeScript types
- `node build-and-verify.js` - Build and verify the project

## Building and Deploying

For simplicity, we've provided two helper scripts:

1. `build-and-verify.js` - Node.js script that:
   - Checks for required assets
   - Installs dependencies
   - Runs type checking
   - Builds the project
   - Verifies the build output

2. `build-and-deploy.bat` - Windows batch file that:
   - Installs required script dependencies
   - Runs the build and verify script
   - Provides user-friendly output

For detailed deployment instructions:
- [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) - General deployment options
- [GITHUB_PAGES_DEPLOYMENT.md](./GITHUB_PAGES_DEPLOYMENT.md) - GitHub Pages specific deployment
- [POST_DEPLOYMENT_CHECKLIST.md](./POST_DEPLOYMENT_CHECKLIST.md) - Post-deployment verification

To set up and deploy to GitHub Pages:

**Option 1: Fully Automated (Silent Mode)**
- Simply run `auto-deploy-silent.bat` - no user interaction required
- GitHub repository creation, pushing code, and deployment happens automatically

**Option 2: Interactive Setup**
1. Run `setup-github-repo.bat` to create GitHub repo and push code
2. Run `npm run deploy` or use `deploy-github-pages.bat`

**Option 3: CI/CD with GitHub Actions**
- After pushing to GitHub, deployment happens automatically via GitHub Actions workflow

## Documentation

This project includes comprehensive documentation:

- [COMPREHENSIVE_FINAL_VALIDATION.md](./COMPREHENSIVE_FINAL_VALIDATION.md) - Detailed verification results
- [FINAL_VERIFICATION_REPORT.md](./FINAL_VERIFICATION_REPORT.md) - Section-by-section verification
- [ASSET_MIGRATION_GUIDE.md](./ASSET_MIGRATION_GUIDE.md) - Instructions for asset migration
- [PROJECT_MAINTENANCE_GUIDE.md](./PROJECT_MAINTENANCE_GUIDE.md) - Guide for future maintenance
- [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) - Implementation summary
- [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) - Deployment instructions
- [FINAL_CHECKLIST.md](./FINAL_CHECKLIST.md) - Final implementation checklist

## Features

### Sections

1. **Header** - Navigation header with logo and links
2. **HeroSection** - Main hero section with parallax background
3. **AboutSection** - About program cards and information
4. **CirclesSection** - Program hierarchy diagram
5. **ActivitiesSection** - Community activities cards
6. **FounderSection** - Founder biography and social links
7. **BenefitsSection** - Program benefits cards
8. **IntroductoryVideoSection** - YouTube video embed
9. **NewsSection** - Community news and updates
10. **CommunityGatheringSection** - Community gathering event cards
11. **ContactSection** - Contact information and links
12. **CommunityPresenceSection** - Social media and platform links
13. **Footer** - Navigation, copyright, and CTA

### Technical Features

- Responsive design for all device sizes
- Keyboard navigation and accessibility features
- Animation effects with performance in mind
- SEO meta tags and semantic HTML
- Progressive enhancement approach

## License

This project is for demonstration purposes only. All rights to the original design and content belong to Elmentor/DevOps Visions.

## Acknowledgements

- Original design and content by Elmentor/DevOps Visions
- Built with React and TypeScript
- Icons from React Icons
- Animations built with CSS
