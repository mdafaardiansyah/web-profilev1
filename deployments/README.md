# Deployment & DevSecOps Documentation

## Overview
Dokumentasi ini menjelaskan implementasi CI/CD pipeline yang telah ditingkatkan dengan DevSecOps practices untuk proyek portfolio.

## Architecture

### CI/CD Pipeline
Pipeline Jenkins telah direfactor dengan stage-stage berikut:

1. **Checkout** - Clone repository
2. **Install Dependencies** - Install npm packages
3. **Code Quality Analysis** - SonarQube static code analysis
4. **Quality Gate** - Verify SonarQube quality standards
5. **Security Scan - Dependencies** - npm audit for dependency vulnerabilities
6. **Build** - Build React application
7. **Docker Build** - Create container image
8. **Security Scan - Container** - Trivy container vulnerability scan
9. **Docker Push** - Push to Docker Hub
10. **Deploy** - Deploy to production server
11. **Smoke Test** - Basic health check

### Security Integration (DevSecOps)

#### SonarQube Integration
- **Purpose**: Static code analysis for code quality, bugs, and security vulnerabilities
- **Configuration**: `sonar-project.properties`
- **Quality Gate**: Pipeline fails if quality standards are not met
- **Metrics Tracked**:
  - Code coverage
  - Duplicated code
  - Maintainability rating
  - Reliability rating
  - Security rating

#### Trivy Security Scanning
- **Purpose**: Container image vulnerability scanning
- **Severity Levels**: CRITICAL and HIGH vulnerabilities fail the build
- **Output**: JSON report archived as build artifact
- **Cache**: Optimized with cache directory for faster scans



## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Node.js 18+ and npm
- Git
- SonarQube Server (for code quality analysis)
- Trivy (for security scanning)

### 1. Automated Environment Setup
```bash
# Linux/Ubuntu - Run automated setup (recommended)
./deployments/setup-environment.sh

# The script will automatically install all required components
```

### 2. Manual Environment Setup
```bash
# Clone the repository
git clone <repository-url>
cd web-profilev1

# Install dependencies
npm install

# Copy environment template
cp .env.example .env
# Edit .env with your configuration
```

### 3. Run Security Scans
```bash
# Linux/Ubuntu - Automated Trivy scan
./deployments/security/trivy-scan.sh --image-name "ardidafa/portfolio:latest"
```

```bash
# Linux/macOS - Automated Trivy scan
./deployments/security/trivy-scan.sh

# Manual Trivy installation and scan
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
trivy image ardidafa/portfolio:latest
trivy fs .
```

### 4. Run Code Quality Analysis
```bash
# Linux/Ubuntu - Automated SonarQube scan
./deployments/quality/sonar-scan.sh --project-key "portfolio-website" --sonar-host-url "https://sonarqube.glanze.space" --sonar-token "your_token"
```

```bash
# Linux/macOS - Automated SonarQube scan
./deployments/quality/sonar-scan.sh

# Manual SonarQube analysis
sonar-scanner \
  -Dsonar.projectKey=portfolio-website \
  -Dsonar.projectName="Portfolio Website" \
  -Dsonar.projectVersion=1.0 \
  -Dsonar.sources=src \
  -Dsonar.host.url=https://sonarqube.glanze.space \
  -Dsonar.login=your_sonar_token
```

### 5. Run Complete Pipeline Locally
```bash
# Linux/Ubuntu - Run complete CI/CD pipeline locally
./deployments/run-pipeline.sh

# The script will run all pipeline stages automatically
```

### 6. Manual Build and Deploy
```bash
# Build the application
npm run build

# Build Docker image
docker build -f deployments/docker/Dockerfile -t ardidafa/portfolio:latest .

# Run the application
docker-compose up -d
```

## 📁 Directory Structure

```
deployments/
├── docker/
│   ├── Dockerfile              # Multi-stage Docker build
│   └── docker-compose.yml      # Application deployment
├── security/
│   └── trivy-scan.sh          # Linux Trivy security scan script
├── quality/
│   └── sonar-scan.sh          # Linux SonarQube scan script
├── jenkins/
│   └── Jenkinsfile            # CI/CD pipeline definition
├── sonar-project.properties   # SonarQube configuration
├── setup-environment.sh      # Automated environment setup
├── run-pipeline.sh           # Local pipeline runner
└── README.md                  # This file
```

## 🛠️ Available Scripts

### Automated Scripts (Recommended)
```bash
# Environment setup
./deployments/setup-environment.sh

# Complete pipeline
./deployments/run-pipeline.sh

# Security scanning
./deployments/security/trivy-scan.sh

# Code quality analysis
./deployments/quality/sonar-scan.sh
```

### Development
```bash
npm start          # Start development server
npm test           # Run tests with coverage
npm run build      # Build production bundle
npm run lint       # Run ESLint
```

### Docker
```bash
# Build and run with Docker Compose
docker-compose up --build

# Stop all services
docker-compose down
```

### Manual Security & Quality
```bash
# Security scan
trivy image ardidafa/portfolio:latest

# Code quality analysis
sonar-scanner

# Dependency audit
npm audit
```

## Setup Instructions

### Prerequisites
1. Jenkins server with required plugins:
   - SonarQube Scanner
   - Docker Pipeline
   - Credentials Binding
2. SonarQube server
3. Docker Hub account
4. Target deployment server

### Jenkins Configuration

#### Required Credentials
Configure the following credentials in Jenkins:

```
- docker-hub: Docker Hub username/password
- docker-hub-pat: Docker Hub Personal Access Token
- sonarqube-token: SonarQube authentication token
- sonarqube-url: SonarQube server URL
- discord-notification: Discord webhook URL
- ip-server-kvm2: Target server IP
- user-ip-kvm2: Target server username
- deploy-server: SSH private key for deployment
```

#### Tools Configuration
1. **NodeJS**: Configure NodeJS 18 installation
2. **SonarQube Scanner**: Configure SonarQube Scanner tool
3. **SonarQube Server**: Configure SonarQube server connection





## Security Best Practices

### Implemented
1. **Credential Management**: All secrets stored in Jenkins credentials
2. **Container Scanning**: Trivy scans for vulnerabilities
3. **Code Quality**: SonarQube enforces quality gates
4. **Dependency Scanning**: npm audit for known vulnerabilities
5. **Least Privilege**: Containers run with minimal permissions

### Recommendations
1. Regular security updates
2. Rotate credentials periodically
3. Monitor security advisories
4. Implement network segmentation
5. Use HTTPS everywhere

## Troubleshooting

### Common Issues

#### Pipeline Failures
1. **SonarQube Quality Gate Failed**
   - Check SonarQube dashboard for specific issues
   - Fix code quality issues
   - Adjust quality gate settings if needed

2. **Trivy Security Scan Failed**
   - Review trivy-report.json artifact
   - Update base images
   - Apply security patches

3. **Deployment Failed**
   - Check SSH connectivity
   - Verify server resources
   - Check Docker service status



### Logs and Debugging
- **Jenkins**: Check build console output

- **Application**: Check browser console for metrics

## Performance Optimization

### Pipeline Optimization
1. **Parallel Stages**: Run independent stages in parallel
2. **Cache Management**: Optimize Docker layer caching
3. **Artifact Management**: Clean up old artifacts

## Future Enhancements

### Planned Improvements
1. **Advanced Alerting**: Integration with external systems
2. **Chaos Engineering**: Resilience testing
3. **Multi-environment**: Staging and production separation

### Scaling Considerations
1. **High Availability**: Multi-instance deployments
2. **Load Balancing**: Distribute traffic
3. **Database Integration**: If database is added
4. **CDN Integration**: Performance optimization

## Compliance and Governance

### Audit Trail
- All pipeline executions logged
- Security scan results archived
- Code quality metrics tracked
- Deployment history maintained

### Reporting
- Weekly security reports
- Monthly performance reviews
- Quarterly architecture assessments

---

**Note**: This documentation should be updated as the system evolves and new features are added.