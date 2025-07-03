<div align="center">

# 🌟 Portfolio Website

*A modern, responsive portfolio website showcasing professional excellence*

[![React](https://img.shields.io/badge/React-18.0+-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://reactjs.org/)
[![Styled Components](https://img.shields.io/badge/Styled_Components-DB7093?style=for-the-badge&logo=styled-components&logoColor=white)](https://styled-components.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins-D33833?style=for-the-badge&logo=jenkins&logoColor=white)](https://www.jenkins.io/)

</div>

---

## 📖 Overview

This is a **modern, responsive portfolio website** built with React.js that showcases professional information, skills, projects, education, and experience in an elegant and interactive user interface. The project implements **DevSecOps best practices** with comprehensive CI/CD pipelines, security scanning, and quality assurance.

## ✨ Features

### 🎨 **User Interface**
- 📱 **Responsive Design** - Works seamlessly on all devices
- 🌙 **Dark Theme UI** - Modern and elegant dark interface
- ⌨️ **Typewriter Effect** - Interactive hero section animation
- 🎯 **Smooth Navigation** - Seamless scrolling and transitions
- 🖼️ **Project Modals** - Detailed project showcase with interactive modals

### 🔧 **Technical Excellence**
- 🚀 **Performance Optimized** - Fast loading and smooth interactions
- 🛡️ **Security First** - Comprehensive security scanning with Trivy
- 📊 **Quality Assured** - SonarQube integration for code quality
- 🔄 **CI/CD Pipeline** - Automated testing, building, and deployment
- 🐳 **Containerized** - Docker support for consistent deployments

## 🛠️ Tech Stack

<div align="center">

| Category | Technologies |
|----------|-------------|
| **Frontend** | ![React](https://img.shields.io/badge/React-61DAFB?style=flat&logo=react&logoColor=black) ![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=flat&logo=javascript&logoColor=black) |
| **Styling** | ![Styled Components](https://img.shields.io/badge/Styled_Components-DB7093?style=flat&logo=styled-components&logoColor=white) ![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=flat&logo=css3&logoColor=white) |
| **UI/UX** | ![Material UI](https://img.shields.io/badge/Material_UI-0081CB?style=flat&logo=mui&logoColor=white) ![React Router](https://img.shields.io/badge/React_Router-CA4245?style=flat&logo=react-router&logoColor=white) |
| **DevOps** | ![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white) ![Jenkins](https://img.shields.io/badge/Jenkins-D33833?style=flat&logo=jenkins&logoColor=white) ![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat&logo=github-actions&logoColor=white) |
| **Quality** | ![SonarQube](https://img.shields.io/badge/SonarQube-4E9BCD?style=flat&logo=sonarqube&logoColor=white) ![Trivy](https://img.shields.io/badge/Trivy-1904DA?style=flat&logo=trivy&logoColor=white) |
| **Deployment** | ![GitHub Pages](https://img.shields.io/badge/GitHub_Pages-222222?style=flat&logo=github&logoColor=white) ![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat&logo=nginx&logoColor=white) |

</div>

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

## 📚 Documentation Hub

<div align="center">

### 🗂️ **Complete Project Documentation**

</div>

| 📋 Document | 🎯 Purpose | 📖 Description |
|-------------|------------|----------------|
| **[📖 Technical Documentation](./DOCUMENTATION.md)** | **Architecture & Implementation** | Comprehensive technical details, component architecture, styling system, and performance optimization strategies |
| **[🧩 Component Guide](./COMPONENT_GUIDE.md)** | **Development & Customization** | Step-by-step guide for creating, modifying, and extending components with best practices and code examples |
| **[📝 Changelog](./CHANGELOG.md)** | **Version History & Updates** | Detailed record of all changes, new features, bug fixes, and DevSecOps implementation milestones |

<div align="center">

### 🚀 **Quick Navigation**

[![Technical Docs](https://img.shields.io/badge/📖_Technical_Documentation-4CAF50?style=for-the-badge&logoColor=white)](./DOCUMENTATION.md)
[![Component Guide](https://img.shields.io/badge/🧩_Component_Guide-2196F3?style=for-the-badge&logoColor=white)](./COMPONENT_GUIDE.md)
[![Changelog](https://img.shields.io/badge/📝_Changelog-FF9800?style=for-the-badge&logoColor=white)](./CHANGELOG.md)

</div>

---

### 📋 **Documentation Overview**

#### 🏗️ **[Technical Documentation](./DOCUMENTATION.md)**
> **Perfect for:** Developers, DevOps Engineers, Technical Leads
> 
> Dive deep into the technical architecture, component structure, styling system, and performance optimizations. Learn about the build process, deployment strategies, and browser compatibility.

#### 🎨 **[Component Guide](./COMPONENT_GUIDE.md)**
> **Perfect for:** Frontend Developers, UI/UX Designers, Contributors
> 
> Master the art of component development with detailed guides on creating, modifying, and extending components. Includes best practices, responsive design patterns, and theming guidelines.

#### 📈 **[Changelog](./CHANGELOG.md)**
> **Perfect for:** Project Managers, Stakeholders, Team Members
> 
> Track the evolution of the project with detailed version history, feature additions, security enhancements, and DevSecOps implementation milestones.
