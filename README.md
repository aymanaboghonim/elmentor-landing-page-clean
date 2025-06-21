# Elmentor Landing Page

A clean, maintainable landing page for the Elmentor/DevOps Visions community built with React, TypeScript, and Vite.

## 📋 Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run serve
```

## 🚀 Deployment

To deploy to GitHub Pages:

1. Update your GitHub username in `github-config.txt`
2. Run the deployment script:
   ```bash
   # PowerShell (recommended)
   ./deploy.ps1
   
   # Or using npm
   npm run deploy
   ```

## 🛠️ Project Structure

```
elmentor-landing-page-clean/
├── dist/              # Build output
├── docs/              # Documentation
├── public/            # Static assets
├── scripts/           # Utility scripts
│   ├── deployment/    # Deployment scripts
│   ├── maintenance/   # Maintenance scripts
│   └── utils/         # Utility scripts
├── .temp/             # Untracked local development files (not in Git)
└── src/               # Source code
```

## 🧩 Features

- Modern React with TypeScript
- Fast builds with Vite
- Responsive design
- Framer Motion animations
- GitHub Pages deployment

## 🧰 Maintenance

For repository maintenance tasks:

```bash
./maintain.ps1
```

## 🔧 Development Utilities

For local development files that shouldn\'t be committed:

```bash
# Move or copy files to untracked .temp directory
./move-to-temp.ps1
```

The `.temp` directory is ignored by Git and provides a standardized location for:
- Development scripts
- Documentation drafts
- Temporary build outputs
- Work-in-progress files

## 📚 Documentation

For detailed documentation, see the `docs` directory:

- [Deployment Guide](docs/deployment/README.md)
- [Development Maintenance](docs/development/maintenance.md)

## 📄 License

This project is licensed under the MIT License.
