# Contributing Guidelines

Thank you for your interest in contributing to the Elmentor Landing Page! This document provides guidelines for contributing to this project.

## Getting Started

### Prerequisites

- Node.js (v18.x or higher)
- npm (v9.x or higher)
- Git

### Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/elmentor-landing-page-clean.git
   cd elmentor-landing-page-clean
   ```
3. Install dependencies:
   ```bash
   npm install
   ```
4. Create a new branch for your feature or fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Guidelines

### Code Style

- Use TypeScript for all JavaScript files
- Follow the existing code formatting style (Prettier is configured)
- Use CSS variables for consistent styling
- Use semantic HTML elements

### Component Structure

- Create new components in appropriate subdirectories
- Use functional components with hooks
- Include proper prop types and interfaces
- Add comments for complex logic

### Testing

- Test your changes in both development and production builds
- Test on multiple browsers and screen sizes
- Verify that all links work correctly
- Check for accessibility issues

## Pull Request Process

1. Update the README.md and documentation with details of changes if needed
2. Make sure your code passes all linting and type checks:
   ```bash
   npm run lint
   npm run typecheck
   ```
3. Build the project to verify it works:
   ```bash
   npm run build
   ```
4. Submit a pull request to the main repository
5. Address any feedback or requested changes

## Commit Guidelines

- Use clear, descriptive commit messages
- Reference issue numbers in commit messages when applicable
- Keep commits focused on single changes or features

## Documentation

- Update documentation when changing functionality
- Add comments to clarify complex code sections
- Keep the README.md up to date

## Branching Strategy

- `main` branch is for stable, production-ready code
- Create feature branches for new features or fixes
- Use `fix/` prefix for bug fixes and `feature/` for new features

## License

By contributing to this project, you agree that your contributions will be licensed under the project's MIT license.
