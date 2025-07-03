#!/bin/bash
# SonarQube Code Quality Analysis Script for Linux/Unix
# This script performs comprehensive code quality analysis using SonarQube

# Parse command line arguments
PROJECT_KEY="portfolio-website"
PROJECT_NAME="Portfolio Website"
PROJECT_VERSION="1.0"
SONAR_HOST_URL="https://sonarqube.glanze.space"
SONAR_TOKEN=""
REPORT_DIR="./quality-reports"

while [[ $# -gt 0 ]]; do
    case $1 in
        --project-key)
            PROJECT_KEY="$2"
            shift 2
            ;;
        --project-name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --project-version)
            PROJECT_VERSION="$2"
            shift 2
            ;;
        --sonar-host-url)
            SONAR_HOST_URL="$2"
            shift 2
            ;;
        --sonar-token)
            SONAR_TOKEN="$2"
            shift 2
            ;;
        --report-dir)
            REPORT_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

# Configuration
DATE=$(date +%Y%m%d_%H%M%S)
SONAR_SCANNER_VERSION="4.8.0.2856"
SONAR_SCANNER_HOME="$HOME/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-linux"
SONAR_SCANNER_BIN="$SONAR_SCANNER_HOME/bin/sonar-scanner"

echo -e "\033[34m📊 Starting SonarQube Code Quality Analysis...\033[0m"
echo -e "\033[34m📅 Analysis Date: $(date)\033[0m"
echo -e "\033[34m🎯 Project: $PROJECT_NAME\033[0m"
echo -e "\033[34m🔗 SonarQube URL: $SONAR_HOST_URL\033[0m"
echo ""

# Create reports directory
if [ ! -d "$REPORT_DIR" ]; then
    mkdir -p "$REPORT_DIR"
fi

# Check if SonarQube Scanner is installed
if [ ! -f "$SONAR_SCANNER_BIN" ]; then
    echo -e "\033[33m⚠️  SonarQube Scanner not found. Installing...\033[0m"
    
    # Create .sonar directory
    mkdir -p "$HOME/.sonar"
    
    # Download and install SonarQube Scanner
    echo -e "\033[33m📦 Downloading SonarQube Scanner...\033[0m"
    cd "$HOME/.sonar"
    
    if command -v wget >/dev/null 2>&1; then
        wget -q "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip"
    elif command -v curl >/dev/null 2>&1; then
        curl -sL "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip" -o "sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip"
    else
        echo -e "\033[31m❌ Neither wget nor curl found. Please install one of them.\033[0m"
        exit 1
    fi
    
    # Extract the scanner
    if command -v unzip >/dev/null 2>&1; then
        unzip -q "sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip"
        rm "sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip"
    else
        echo -e "\033[31m❌ unzip not found. Please install unzip.\033[0m"
        exit 1
    fi
    
    # Make scanner executable
    chmod +x "$SONAR_SCANNER_BIN"
    
    # Return to original directory
    cd - >/dev/null
    
    echo -e "\033[32m✅ SonarQube Scanner installed successfully\033[0m"
else
    echo -e "\033[32m✅ SonarQube Scanner is available\033[0m"
fi

# Check if SonarQube server is accessible
echo -e "\033[33m🔍 Checking SonarQube server connectivity...\033[0m"
if command -v curl >/dev/null 2>&1; then
    if curl -s --connect-timeout 10 "$SONAR_HOST_URL/api/system/status" >/dev/null; then
        echo -e "\033[32m✅ SonarQube server is accessible\033[0m"
    else
        echo -e "\033[31m❌ SonarQube server is not accessible at $SONAR_HOST_URL\033[0m"
        echo -e "\033[33m💡 Please ensure SonarQube is running and accessible\033[0m"
        echo -e "\033[33m💡 You can start SonarQube using: docker-compose up -d sonarqube\033[0m"
        exit 1
    fi
else
    echo -e "\033[33m⚠️  curl not available, skipping connectivity check\033[0m"
fi

# Install dependencies if package.json exists
if [ -f "package.json" ]; then
    echo -e "\033[34m📦 Installing dependencies...\033[0m"
    if command -v npm >/dev/null 2>&1; then
        npm install --silent
    else
        echo -e "\033[33m⚠️  npm not found, skipping dependency installation\033[0m"
    fi
fi

# Run tests with coverage if test script exists
if [ -f "package.json" ] && command -v npm >/dev/null 2>&1; then
    if npm run --silent test --dry-run >/dev/null 2>&1; then
        echo -e "\033[34m🧪 Running tests with coverage...\033[0m"
        npm run test -- --coverage --watchAll=false --silent 2>/dev/null || {
            echo -e "\033[33m⚠️  Tests failed or no coverage generated\033[0m"
        }
    else
        echo -e "\033[33m⚠️  No test script found in package.json\033[0m"
    fi
fi

# Generate sonar-project.properties file
echo -e "\033[34m📝 Generating sonar-project.properties...\033[0m"
cat > sonar-project.properties << EOF
# SonarQube Project Configuration
sonar.projectKey=$PROJECT_KEY
sonar.projectName=$PROJECT_NAME
sonar.projectVersion=$PROJECT_VERSION

# Source code settings
sonar.sources=src
sonar.sourceEncoding=UTF-8

# Language specific settings
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.typescript.lcov.reportPaths=coverage/lcov.info
sonar.coverage.exclusions=**/*.test.js,**/*.test.jsx,**/*.test.ts,**/*.test.tsx,**/node_modules/**,**/coverage/**,**/build/**,**/dist/**

# Exclusions
sonar.exclusions=**/node_modules/**,**/coverage/**,**/build/**,**/dist/**,**/*.min.js,**/*.bundle.js
sonar.test.exclusions=**/*.test.js,**/*.test.jsx,**/*.test.ts,**/*.test.tsx,**/*.spec.js,**/*.spec.jsx,**/*.spec.ts,**/*.spec.tsx

# Duplication exclusions
sonar.cpd.exclusions=**/*.test.js,**/*.test.jsx,**/*.test.ts,**/*.test.tsx
EOF

# Run SonarQube analysis
echo -e "\033[34m🔍 Running SonarQube analysis...\033[0m"
echo ""

# Prepare scanner arguments
SCANNER_ARGS=""
if [ -n "$SONAR_TOKEN" ]; then
    SCANNER_ARGS="$SCANNER_ARGS -Dsonar.login=$SONAR_TOKEN"
fi

SCANNER_ARGS="$SCANNER_ARGS -Dsonar.host.url=$SONAR_HOST_URL"
SCANNER_ARGS="$SCANNER_ARGS -Dsonar.projectBaseDir=."

# Execute the scanner
if "$SONAR_SCANNER_BIN" $SCANNER_ARGS; then
    echo ""
    echo -e "\033[32m✅ SonarQube analysis completed successfully!\033[0m"
    ANALYSIS_SUCCESS=true
else
    echo ""
    echo -e "\033[31m❌ SonarQube analysis failed!\033[0m"
    ANALYSIS_SUCCESS=false
fi

# Generate summary report
echo -e "\033[34m📊 Generating summary report...\033[0m"
SUMMARY_FILE="$REPORT_DIR/sonar-summary-$DATE.txt"

cat > "$SUMMARY_FILE" << EOF
===========================================
SONARQUBE CODE QUALITY ANALYSIS SUMMARY
===========================================
Analysis Date: $(date)
Project Key: $PROJECT_KEY
Project Name: $PROJECT_NAME
Project Version: $PROJECT_VERSION
SonarQube URL: $SONAR_HOST_URL
Analyzed by: $(whoami)
Host: $(hostname)

===========================================
ANALYSIS CONFIGURATION
===========================================
Source Directory: src/
Coverage Reports: coverage/lcov.info
Exclusions: node_modules, coverage, build, dist, *.min.js
Test Exclusions: *.test.*, *.spec.*

===========================================
ANALYSIS STATUS
===========================================
EOF

if [ "$ANALYSIS_SUCCESS" = true ]; then
    echo "Status: ✅ SUCCESS" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
    echo "🔗 View detailed results at: $SONAR_HOST_URL/dashboard?id=$PROJECT_KEY" >> "$SUMMARY_FILE"
else
    echo "Status: ❌ FAILED" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
    echo "❌ Analysis failed. Please check the logs above for details." >> "$SUMMARY_FILE"
fi

cat >> "$SUMMARY_FILE" << EOF

===========================================
RECOMMENDATIONS
===========================================
1. Review code quality issues in SonarQube dashboard
2. Address security vulnerabilities and code smells
3. Improve test coverage to meet quality gate requirements
4. Follow coding standards and best practices
5. Set up quality gates for CI/CD pipeline integration

Generated files:
- sonar-project.properties (SonarQube configuration)
- $SUMMARY_FILE (This summary)

For detailed analysis, visit: $SONAR_HOST_URL/dashboard?id=$PROJECT_KEY
EOF

# Display results
echo ""
echo -e "\033[34m📋 Analysis Summary:\033[0m"
cat "$SUMMARY_FILE"

# Clean up
echo ""
echo -e "\033[34m🧹 Cleaning up temporary files...\033[0m"
if [ -f "sonar-project.properties" ]; then
    echo -e "\033[33m💾 Keeping sonar-project.properties for future use\033[0m"
fi

# Final status
echo ""
if [ "$ANALYSIS_SUCCESS" = true ]; then
    echo -e "\033[32m🎉 Code quality analysis completed successfully!\033[0m"
    echo -e "\033[34m🔗 View results: $SONAR_HOST_URL/dashboard?id=$PROJECT_KEY\033[0m"
    
    # Optional: Open SonarQube dashboard
    read -p "Would you like to open SonarQube dashboard? (y/N): " open_dashboard
    if [[ "$open_dashboard" =~ ^[Yy]$ ]]; then
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$SONAR_HOST_URL/dashboard?id=$PROJECT_KEY"
        elif command -v open >/dev/null 2>&1; then
            open "$SONAR_HOST_URL/dashboard?id=$PROJECT_KEY"
        else
            echo "🌐 Please open $SONAR_HOST_URL/dashboard?id=$PROJECT_KEY manually"
        fi
        echo -e "\033[32m🌐 Opened SonarQube dashboard\033[0m"
    fi
else
    echo -e "\033[31m❌ Code quality analysis failed!\033[0m"
    echo -e "\033[33m💡 Please check the error messages above and try again\033[0m"
    exit 1
fi

echo ""
echo -e "\033[34m📚 SonarQube documentation: https://docs.sonarqube.org/\033[0m"