# Portfolio Website

## Overview
This is a modern, responsive portfolio website built with React.js. It showcases professional information, skills, projects, education, and experience in an elegant and interactive user interface.

## Features
- Responsive design that works on all devices
- Dark theme UI
- Interactive hero section with typewriter effect
- Sections for About, Skills, Experience, Projects, and Education
- Project details modal for showcasing individual projects
- Smooth scrolling and animations

## Tech Stack
- **Frontend Framework**: React.js
- **Styling**: Styled Components, CSS
- **Animation Libraries**: Typewriter Effect
- **Routing**: React Router
- **UI Components**: Material UI
- **Deployment**: GitHub Pages

## Project Structure
```
web-profilev1/
├── public/                # Public assets
├── src/                   # Source files
│   ├── components/        # React components
│   │   ├── AboutMe/       # About section component
│   │   ├── Education/     # Education section component
│   │   ├── Experience/    # Experience section component
│   │   ├── Footer/        # Footer component
│   │   ├── HeroBgAnimation/ # Hero background animation
│   │   ├── HeroSection/   # Hero section component
│   │   ├── Navbar/        # Navigation bar component
│   │   ├── ProjectDetails/ # Project details modal
│   │   ├── Projects/      # Projects section component
│   │   └── Skills/        # Skills section component
│   ├── data/              # Data files
│   │   └── constants.js   # Website content and configuration
│   ├── images/            # Image assets
│   ├── utils/             # Utility functions
│   │   └── Themes.js      # Theme configuration
│   ├── App.css            # Global styles
│   ├── App.js             # Main application component
│   └── index.js           # Application entry point
├── deployments/           # Deployment configurations
│   ├── docker/            # Docker configuration
│   ├── jenkins/           # Jenkins pipeline
│   └── nginx/             # Nginx configuration
├── .github/               # GitHub workflows
├── package.json           # Dependencies and scripts
└── README.md              # Project documentation
```

## Getting Started

### Prerequisites
- Node.js (v14.0.0 or later)
- npm (v6.0.0 or later)

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/web-profilev1.git
   cd web-profilev1
   ```

2. Install dependencies
   ```bash
   npm install
   ```

3. Start the development server
   ```bash
   npm start
   ```
   The application will open in your default browser at `http://localhost:3000`.

### Building for Production

```bash
npm run build
```

This will create an optimized production build in the `build` folder.

## Deployment

### Docker Deployment

A Docker configuration is included for containerized deployment:

```bash
docker compose up -d
```

## Customization

### Content
All website content is stored in `src/data/constants.js`. You can modify this file to update:
- Personal information
- Skills
- Experience
- Projects
- Education

### Styling
The website uses a combination of Styled Components and CSS:
- Global styles are in `src/App.css`
- Component-specific styles are in their respective folders
- Theme configuration is in `src/utils/Themes.js`

## CI/CD Pipeline

This project includes CI/CD configurations:
- GitHub Actions workflow in `.github/workflows/cicd.yml`
- Jenkins pipeline in `deployments/jenkins/Jenkinsfile`

## Dokumentasi

This Project has documentation for technical details and component development:

- [Technical Documentation](./DOCUMENTATION.md) - Technical details of the project.
- [Component Documentation](./COMPONENT_GUIDE.md) - Guide for use the components.
