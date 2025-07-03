#!/bin/bash
# Environment Setup Script for DevSecOps Pipeline
# This script sets up the development environment with all necessary tools and configurations

# Parse command line arguments
INSTALL_DOCKER=false
INSTALL_NODE=false
INSTALL_TOOLS=false
SETUP_SONARQUBE=false
ALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --install-docker)
            INSTALL_DOCKER=true
            shift
            ;;
        --install-node)
            INSTALL_NODE=true
            shift
            ;;
        --install-tools)
            INSTALL_TOOLS=true
            shift
            ;;
        --setup-sonarqube)
            SETUP_SONARQUBE=true
            shift
            ;;
        --all)
            ALL=true
            shift
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

# If --all is specified, enable all options
if [ "$ALL" = true ]; then
    INSTALL_DOCKER=true
    INSTALL_NODE=true
    INSTALL_TOOLS=true
    SETUP_SONARQUBE=true
fi

# Configuration
LOG_FILE="setup-$(date +%Y%m%d_%H%M%S).log"

# Function to log messages
write_setup_log() {
    local message="$1"
    local level="${2:-INFO}"
    local color="${3:-white}"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_message="[$timestamp] [$level] $message"
    
    case $color in
        "blue") echo -e "\033[34m$log_message\033[0m" ;;
        "green") echo -e "\033[32m$log_message\033[0m" ;;
        "yellow") echo -e "\033[33m$log_message\033[0m" ;;
        "red") echo -e "\033[31m$log_message\033[0m" ;;
        "cyan") echo -e "\033[36m$log_message\033[0m" ;;
        "gray") echo -e "\033[90m$log_message\033[0m" ;;
        *) echo "$log_message" ;;
    esac
    
    echo "$log_message" >> "$LOG_FILE"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
}

# Header
echo ""
echo -e "\033[36m🚀 ===================================\033[0m"
echo -e "\033[36m🚀 DEVSECOPS ENVIRONMENT SETUP\033[0m"
echo -e "\033[36m🚀 ===================================\033[0m"
echo -e "\033[90m📅 Setup Date: $(date)\033[0m"
echo -e "\033[90m💻 System: $(hostname)\033[0m"
echo -e "\033[90m👤 User: $(whoami)\033[0m"
echo -e "\033[90m📁 Log: $LOG_FILE\033[0m"
echo ""

write_setup_log "🚀 Starting DevSecOps environment setup" "INFO" "cyan"

# Detect OS
detect_os
write_setup_log "🖥️  Detected OS: $OS $VER" "INFO" "gray"

# Check if running as root
if check_root; then
    write_setup_log "⚠️  Running as root. This is recommended for system-wide installations." "WARN" "yellow"
else
    write_setup_log "💡 Not running as root. Some installations may require sudo." "INFO" "yellow"
fi

# Update package manager
write_setup_log "📦 Updating package manager..." "INFO" "blue"
if command_exists apt-get; then
    sudo apt-get update
elif command_exists yum; then
    sudo yum update -y
elif command_exists dnf; then
    sudo dnf update -y
else
    write_setup_log "⚠️  Unknown package manager. Please update manually." "WARN" "yellow"
fi

# Install Docker
if [ "$INSTALL_DOCKER" = true ]; then
    write_setup_log "🐳 Setting up Docker..." "INFO" "blue"
    
    if ! command_exists docker; then
        write_setup_log "📦 Installing Docker..." "INFO" "blue"
        
        if command_exists apt-get; then
            # Ubuntu/Debian
            sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        elif command_exists yum; then
            # CentOS/RHEL
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        elif command_exists dnf; then
            # Fedora
            sudo dnf -y install dnf-plugins-core
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        fi
        
        # Start and enable Docker
        sudo systemctl start docker
        sudo systemctl enable docker
        
        # Add current user to docker group
        sudo usermod -aG docker "$(whoami)"
        
        write_setup_log "✅ Docker installed successfully. Please log out and back in to use Docker without sudo." "SUCCESS" "green"
    else
        write_setup_log "✅ Docker is already installed" "SUCCESS" "green"
        
        # Test Docker
        if docker --version >/dev/null 2>&1; then
            write_setup_log "✅ Docker is working correctly" "SUCCESS" "green"
        else
            write_setup_log "⚠️  Docker is installed but not accessible. You may need to log out and back in." "WARN" "yellow"
        fi
    fi
fi

# Install Node.js
if [ "$INSTALL_NODE" = true ]; then
    write_setup_log "📦 Setting up Node.js..." "INFO" "blue"
    
    if ! command_exists node; then
        write_setup_log "📦 Installing Node.js LTS..." "INFO" "blue"
        
        # Install Node.js using NodeSource repository
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        
        if command_exists apt-get; then
            sudo apt-get install -y nodejs
        elif command_exists yum; then
            sudo yum install -y nodejs npm
        elif command_exists dnf; then
            sudo dnf install -y nodejs npm
        fi
        
        write_setup_log "✅ Node.js installed successfully" "SUCCESS" "green"
    else
        local node_version=$(node --version)
        write_setup_log "✅ Node.js is already installed: $node_version" "SUCCESS" "green"
    fi
    
    # Check npm
    if command_exists npm; then
        local npm_version=$(npm --version)
        write_setup_log "✅ npm is available: $npm_version" "SUCCESS" "green"
    fi
fi

# Install Development Tools
if [ "$INSTALL_TOOLS" = true ]; then
    write_setup_log "🛠️  Installing development tools..." "INFO" "blue"
    
    local tools=("git" "curl" "wget" "jq" "unzip")
    
    for tool in "${tools[@]}"; do
        if ! command_exists "$tool"; then
            write_setup_log "📦 Installing $tool..." "INFO" "blue"
            
            if command_exists apt-get; then
                sudo apt-get install -y "$tool"
            elif command_exists yum; then
                sudo yum install -y "$tool"
            elif command_exists dnf; then
                sudo dnf install -y "$tool"
            fi
            
            if command_exists "$tool"; then
                write_setup_log "✅ $tool installed successfully" "SUCCESS" "green"
            else
                write_setup_log "⚠️  Failed to install $tool" "WARN" "yellow"
            fi
        else
            write_setup_log "✅ $tool is already installed" "SUCCESS" "green"
        fi
    done
fi

# Setup SonarQube
if [ "$SETUP_SONARQUBE" = true ]; then
    write_setup_log "📊 Setting up SonarQube..." "INFO" "blue"
    
    # Create SonarQube docker-compose file
    local sonar_compose_content='version: "3.8"
services:
  sonarqube:
    image: sonarqube:community
    container_name: sonarqube
    ports:
      - "9000:9000"
    environment:
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_extensions:/opt/sonarqube/extensions
    networks:
      - sonar-network

volumes:
  sonarqube_data:
  sonarqube_logs:
  sonarqube_extensions:

networks:
  sonar-network:
    driver: bridge'
    
    local sonar_dir="./sonarqube"
    if [ ! -d "$sonar_dir" ]; then
        mkdir -p "$sonar_dir"
    fi
    
    echo "$sonar_compose_content" > "$sonar_dir/docker-compose.yml"
    write_setup_log "✅ SonarQube docker-compose.yml created" "SUCCESS" "green"
    
    write_setup_log "💡 To start SonarQube: cd sonarqube && docker-compose up -d" "INFO" "yellow"
    write_setup_log "💡 SonarQube will be available at: http://localhost:9000" "INFO" "yellow"
    write_setup_log "💡 Default credentials: admin/admin" "INFO" "yellow"
fi

# Create environment configuration file
write_setup_log "📝 Creating environment configuration..." "INFO" "blue"

local env_config="# DevSecOps Environment Configuration
# Generated on $(date)

# Docker Configuration
DOCKER_REGISTRY=ardidafa
IMAGE_NAME=portfolio
IMAGE_TAG=latest

# SonarQube Configuration
SONAR_HOST_URL=https://sonarqube.glanze.space
SONAR_PROJECT_KEY=portfolio-website
SONAR_PROJECT_NAME=Portfolio Website
# SONAR_TOKEN=your_sonarqube_token_here

# Security Configuration
TRIVY_CACHE_DIR=\$HOME/.cache/trivy

# Notification Configuration (Optional)
# SLACK_WEBHOOK_URL=your_slack_webhook_url
# EMAIL_RECIPIENTS=your-email@example.com

# Jenkins Configuration (if using Jenkins)
# JENKINS_URL=http://localhost:8080
# JENKINS_USER=admin
# JENKINS_TOKEN=your_jenkins_token"

echo "$env_config" > ".env.example"
write_setup_log "✅ Environment configuration template created: .env.example" "SUCCESS" "green"

# Create quick start guide
local quick_start_content='# 🚀 DevSecOps Pipeline Quick Start Guide

## Prerequisites Installed
- ✅ Docker
- ✅ Node.js & npm
- ✅ Development tools (Git, curl, wget, etc.)
- ✅ SonarQube setup

## Quick Commands

### 1. Start Development Environment
```bash
# Install project dependencies
npm install

# Start development server
npm start
```

### 2. Run Local Pipeline
```bash
# Run complete pipeline
./deployments/run-pipeline.sh

# Run pipeline with specific stages
./deployments/run-pipeline.sh --skip-tests --skip-security
```

### 3. Start SonarQube
```bash
cd sonarqube
docker-compose up -d

# Access SonarQube: http://localhost:9000 (admin/admin)
```

### 4. Run Security Scans
```bash
# Run Trivy security scan
./deployments/security/trivy-scan.sh

# Run SonarQube code quality scan
./deployments/quality/sonar-scan.sh
```

### 5. Environment Configuration
1. Copy `.env.example` to `.env`
2. Update the values with your specific configuration
3. Source the environment file: `source .env`

## Troubleshooting

### Docker Issues
- Ensure Docker service is running: `sudo systemctl status docker`
- Start Docker if needed: `sudo systemctl start docker`
- Check if user is in docker group: `groups`

### Node.js Issues
- Clear npm cache: `npm cache clean --force`
- Delete node_modules and reinstall: `rm -rf node_modules && npm install`

### Permission Issues
- Check file permissions: `ls -la`
- Make scripts executable: `chmod +x deployments/*.sh`

## Next Steps
1. Configure your CI/CD pipeline (Jenkins/GitHub Actions)
2. Set up notification channels (Slack, Email)
3. Configure quality gates in SonarQube
4. Integrate with your deployment environment

## Documentation
- [Pipeline Documentation](./deployments/README.md)
- [Security Guidelines](./deployments/security/README.md)'

echo "$quick_start_content" > "QUICKSTART.md"
write_setup_log "✅ Quick start guide created: QUICKSTART.md" "SUCCESS" "green"

# Summary
echo ""
echo -e "\033[32m🎉 ===================================\033[0m"
echo -e "\033[32m🎉 ENVIRONMENT SETUP COMPLETED!\033[0m"
echo -e "\033[32m🎉 ===================================\033[0m"
echo -e "\033[90m📋 Setup Summary:\033[0m"

if [ "$INSTALL_DOCKER" = true ]; then echo -e "\033[32m   🐳 Docker: Configured\033[0m"; fi
if [ "$INSTALL_NODE" = true ]; then echo -e "\033[32m   📦 Node.js: Installed\033[0m"; fi
if [ "$INSTALL_TOOLS" = true ]; then echo -e "\033[32m   🛠️  Development Tools: Installed\033[0m"; fi
if [ "$SETUP_SONARQUBE" = true ]; then echo -e "\033[32m   📊 SonarQube: Configured\033[0m"; fi

echo -e "\033[32m   📝 Configuration: .env.example created\033[0m"
echo -e "\033[32m   📚 Documentation: QUICKSTART.md created\033[0m"
echo -e "\033[90m   📁 Logs: $LOG_FILE\033[0m"
echo ""

write_setup_log "🎉 Environment setup completed successfully" "SUCCESS" "green"

echo -e "\033[36m🚀 Next Steps:\033[0m"
echo -e "\033[37m   1. Read QUICKSTART.md for usage instructions\033[0m"
echo -e "\033[37m   2. Copy .env.example to .env and configure\033[0m"
echo -e "\033[37m   3. Start your development environment\033[0m"
echo -e "\033[37m   4. Run the local pipeline: ./deployments/run-pipeline.sh\033[0m"
echo ""

# Optional: Open quick start guide
read -p "Would you like to open the Quick Start guide? (y/N): " open_guide
if [[ "$open_guide" =~ ^[Yy]$ ]]; then
    if command_exists xdg-open; then
        xdg-open "QUICKSTART.md"
    elif command_exists open; then
        open "QUICKSTART.md"
    else
        echo "📖 Please open QUICKSTART.md manually"
    fi
    echo -e "\033[32m📖 Opened Quick Start guide\033[0m"
fi