#!/bin/bash
# Local CI/CD Pipeline Runner for Linux/Unix
# This script simulates the Jenkins pipeline locally for testing and development

# Parse command line arguments
SKIP_TESTS=false
SKIP_SECURITY=false
SKIP_QUALITY=false
SKIP_BUILD=false
IMAGE_TAG="latest"
DOCKER_REGISTRY="ardidafa"
PROJECT_NAME="portfolio"

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --skip-security)
            SKIP_SECURITY=true
            shift
            ;;
        --skip-quality)
            SKIP_QUALITY=true
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --image-tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        --docker-registry)
            DOCKER_REGISTRY="$2"
            shift 2
            ;;
        --project-name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

# Configuration
START_TIME=$(date)
LOG_DIR="./pipeline-logs"
DATE=$(date +%Y%m%d_%H%M%S)
IMAGE_NAME="$DOCKER_REGISTRY/$PROJECT_NAME:$IMAGE_TAG"

# Create logs directory
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
fi

# Function to log messages
write_pipeline_log() {
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
    
    echo "$log_message" >> "$LOG_DIR/pipeline-$DATE.log"
}

# Function to run stage
invoke_pipeline_stage() {
    local stage_name="$1"
    local stage_script="$2"
    local skip="${3:-false}"
    
    if [ "$skip" = true ]; then
        write_pipeline_log "⏭️  Skipping stage: $stage_name" "SKIP" "yellow"
        return 0
    fi
    
    write_pipeline_log "🚀 Starting stage: $stage_name" "INFO" "blue"
    local stage_start=$(date +%s)
    
    if eval "$stage_script"; then
        local stage_end=$(date +%s)
        local duration=$((stage_end - stage_start))
        local minutes=$((duration / 60))
        local seconds=$((duration % 60))
        write_pipeline_log "✅ Stage completed: $stage_name (Duration: $(printf "%02d:%02d" $minutes $seconds))" "SUCCESS" "green"
        return 0
    else
        local stage_end=$(date +%s)
        local duration=$((stage_end - stage_start))
        local minutes=$((duration / 60))
        local seconds=$((duration % 60))
        write_pipeline_log "❌ Stage failed: $stage_name (Duration: $(printf "%02d:%02d" $minutes $seconds))" "ERROR" "red"
        return 1
    fi
}

# Pipeline Header
echo ""
echo -e "\033[36m🔄 ===================================\033[0m"
echo -e "\033[36m🔄 LOCAL CI/CD PIPELINE RUNNER\033[0m"
echo -e "\033[36m🔄 ===================================\033[0m"
echo -e "\033[90m📅 Start Time: $START_TIME\033[0m"
echo -e "\033[90m🎯 Project: $PROJECT_NAME\033[0m"
echo -e "\033[90m🐳 Image: $IMAGE_NAME\033[0m"
echo -e "\033[90m📁 Logs: $LOG_DIR/pipeline-$DATE.log\033[0m"
echo ""

# Stage 1: Checkout (Simulated)
if ! invoke_pipeline_stage "Checkout" '
    write_pipeline_log "📥 Simulating git checkout..." "INFO" "gray"
    write_pipeline_log "✅ Working directory: $(pwd)" "INFO" "gray"
    
    # Verify we are in the right directory
    if [ ! -f "package.json" ]; then
        write_pipeline_log "❌ package.json not found. Make sure you are in the project root directory." "ERROR" "red"
        exit 1
    fi
    
    write_pipeline_log "✅ Project files verified" "INFO" "gray"
'; then
    exit 1
fi

# Stage 2: Install Dependencies
if ! invoke_pipeline_stage "Install Dependencies" '
    write_pipeline_log "📦 Installing npm dependencies..." "INFO" "gray"
    
    # Clean install
    if [ -d "node_modules" ]; then
        write_pipeline_log "🧹 Cleaning existing node_modules..." "INFO" "gray"
        rm -rf node_modules
    fi
    
    if [ -f "package-lock.json" ]; then
        npm ci
    else
        npm install
    fi
    
    if [ $? -ne 0 ]; then
        write_pipeline_log "❌ npm install failed" "ERROR" "red"
        exit 1
    fi
    
    write_pipeline_log "✅ Dependencies installed successfully" "INFO" "gray"
'; then
    exit 1
fi

# Stage 3: Security Scan - Dependencies
if ! invoke_pipeline_stage "Security Scan - Dependencies" '
    write_pipeline_log "🔒 Running npm audit..." "INFO" "gray"
    
    # Run npm audit
    npm audit --audit-level=high > "$LOG_DIR/npm-audit-$DATE.log" 2>&1
    local audit_exit_code=$?
    
    if [ $audit_exit_code -ne 0 ]; then
        write_pipeline_log "⚠️  npm audit found vulnerabilities (exit code: $audit_exit_code)" "WARN" "yellow"
        write_pipeline_log "📄 Audit report saved to: $LOG_DIR/npm-audit-$DATE.log" "INFO" "gray"
    else
        write_pipeline_log "✅ No high/critical vulnerabilities found" "INFO" "gray"
    fi
' "$SKIP_SECURITY"; then
    exit 1
fi

# Stage 4: SonarQube Code Quality Analysis
if ! invoke_pipeline_stage "SonarQube Code Quality Analysis" '
    write_pipeline_log "📊 Running SonarQube analysis..." "INFO" "gray"
    
    if [ -f "./deployments/quality/sonar-scan.sh" ]; then
        chmod +x "./deployments/quality/sonar-scan.sh"
        "./deployments/quality/sonar-scan.sh" --project-key "$PROJECT_NAME-local" --project-name "$PROJECT_NAME Local Build" --report-dir "$LOG_DIR"
        
        if [ $? -ne 0 ]; then
            write_pipeline_log "⚠️  SonarQube analysis completed with warnings" "WARN" "yellow"
        else
            write_pipeline_log "✅ SonarQube analysis completed successfully" "INFO" "gray"
        fi
    else
        write_pipeline_log "⚠️  SonarQube scan script not found, skipping..." "WARN" "yellow"
    fi
' "$SKIP_QUALITY"; then
    exit 1
fi

# Stage 5: Run Tests
if ! invoke_pipeline_stage "Run Tests" '
    write_pipeline_log "🧪 Running tests..." "INFO" "gray"
    
    # Check if test script exists
    if [ -f "package.json" ] && jq -e ".scripts.test" package.json > /dev/null; then
        npm test -- --coverage --watchAll=false --testResultsProcessor=jest-sonar-reporter
        
        if [ $? -ne 0 ]; then
            write_pipeline_log "❌ Tests failed" "ERROR" "red"
            exit 1
        fi
        
        write_pipeline_log "✅ All tests passed" "INFO" "gray"
        
        # Check coverage
        if [ -f "coverage/lcov-report/index.html" ]; then
            write_pipeline_log "📊 Coverage report generated: coverage/lcov-report/index.html" "INFO" "gray"
        fi
    else
        write_pipeline_log "⚠️  No test script found in package.json" "WARN" "yellow"
    fi
' "$SKIP_TESTS"; then
    exit 1
fi

# Stage 6: Build Application
if ! invoke_pipeline_stage "Build Application" '
    write_pipeline_log "🏗️  Building application..." "INFO" "gray"
    
    # Check if build script exists
    if [ -f "package.json" ] && jq -e ".scripts.build" package.json > /dev/null; then
        npm run build
        
        if [ $? -ne 0 ]; then
            write_pipeline_log "❌ Build failed" "ERROR" "red"
            exit 1
        fi
        
        write_pipeline_log "✅ Application built successfully" "INFO" "gray"
        
        # Verify build output
        if [ -d "build" ]; then
            local build_size=$(du -sh build | cut -f1)
            write_pipeline_log "📦 Build size: $build_size" "INFO" "gray"
        fi
    else
        write_pipeline_log "⚠️  No build script found in package.json" "WARN" "yellow"
    fi
' "$SKIP_BUILD"; then
    exit 1
fi

# Stage 7: Docker Build
if ! invoke_pipeline_stage "Docker Build" '
    write_pipeline_log "🐳 Building Docker image..." "INFO" "gray"
    
    # Check if Dockerfile exists
    local dockerfile_path="deployments/docker/Dockerfile"
    if [ ! -f "$dockerfile_path" ]; then
        dockerfile_path="Dockerfile"
    fi
    
    if [ -f "$dockerfile_path" ]; then
        docker build -f "$dockerfile_path" -t "$IMAGE_NAME" .
        
        if [ $? -ne 0 ]; then
            write_pipeline_log "❌ Docker build failed" "ERROR" "red"
            exit 1
        fi
        
        write_pipeline_log "✅ Docker image built: $IMAGE_NAME" "INFO" "gray"
        
        # Get image size
        local image_size=$(docker images "$IMAGE_NAME" --format "{{.Size}}" | head -1)
        write_pipeline_log "📦 Image size: $image_size" "INFO" "gray"
    else
        write_pipeline_log "❌ Dockerfile not found in expected locations" "ERROR" "red"
        exit 1
    fi
' "$SKIP_BUILD"; then
    exit 1
fi

# Stage 8: Security Scan - Container
if ! invoke_pipeline_stage "Security Scan - Container" '
    write_pipeline_log "🔒 Running Trivy container scan..." "INFO" "gray"
    
    if [ -f "./deployments/security/trivy-scan.sh" ]; then
        chmod +x "./deployments/security/trivy-scan.sh"
        "./deployments/security/trivy-scan.sh" --image-name "$IMAGE_NAME" --report-dir "$LOG_DIR"
        
        if [ $? -ne 0 ]; then
            write_pipeline_log "⚠️  Trivy scan found critical vulnerabilities" "WARN" "yellow"
        else
            write_pipeline_log "✅ Container security scan completed" "INFO" "gray"
        fi
    else
        write_pipeline_log "⚠️  Trivy scan script not found, skipping..." "WARN" "yellow"
    fi
' "$SKIP_SECURITY"; then
    exit 1
fi

# Stage 9: Smoke Test
if ! invoke_pipeline_stage "Smoke Test" '
    write_pipeline_log "🧪 Running smoke tests..." "INFO" "gray"
    
    # Test if Docker image can run
    write_pipeline_log "🐳 Testing Docker image..." "INFO" "gray"
    local container_id=$(docker run -d -p 3003:80 "$IMAGE_NAME")
    
    if [ $? -ne 0 ]; then
        write_pipeline_log "❌ Failed to start container" "ERROR" "red"
        exit 1
    fi
    
    # Wait for container to start
    sleep 10
    
    # Test health endpoint
    local response_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3003 || echo "000")
    
    # Clean up container
    docker stop "$container_id" > /dev/null
    docker rm "$container_id" > /dev/null
    write_pipeline_log "🧹 Test container cleaned up" "INFO" "gray"
    
    if [ "$response_code" = "200" ]; then
        write_pipeline_log "✅ Smoke test passed - Application is responding" "INFO" "gray"
    else
        write_pipeline_log "❌ Application returned status code: $response_code" "ERROR" "red"
        exit 1
    fi
'; then
    exit 1
fi

# Pipeline Summary
local end_time=$(date)
local start_timestamp=$(date -d "$START_TIME" +%s)
local end_timestamp=$(date +%s)
local total_duration=$((end_timestamp - start_timestamp))
local total_minutes=$((total_duration / 60))
local total_seconds=$((total_duration % 60))

echo ""
echo -e "\033[32m🎉 ===================================\033[0m"
echo -e "\033[32m🎉 PIPELINE COMPLETED SUCCESSFULLY!\033[0m"
echo -e "\033[32m🎉 ===================================\033[0m"
echo -e "\033[90m⏱️  Total Duration: $(printf "%02d:%02d" $total_minutes $total_seconds)\033[0m"
echo -e "\033[90m📅 End Time: $end_time\033[0m"
echo -e "\033[90m🐳 Image Built: $IMAGE_NAME\033[0m"
echo -e "\033[90m📁 Logs: $LOG_DIR/pipeline-$DATE.log\033[0m"
echo ""

write_pipeline_log "🎉 Pipeline completed successfully in $(printf "%02d:%02d" $total_minutes $total_seconds)" "SUCCESS" "green"

# Generate pipeline report
local report_file="$LOG_DIR/pipeline-report-$DATE.html"
cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Pipeline Report - $DATE</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f0f0f0; padding: 20px; border-radius: 5px; }
        .success { color: green; }
        .warning { color: orange; }
        .error { color: red; }
        .stage { margin: 10px 0; padding: 10px; border-left: 3px solid #ccc; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔄 CI/CD Pipeline Report</h1>
        <p><strong>Project:</strong> $PROJECT_NAME</p>
        <p><strong>Image:</strong> $IMAGE_NAME</p>
        <p><strong>Duration:</strong> $(printf "%02d:%02d" $total_minutes $total_seconds)</p>
        <p><strong>Status:</strong> <span class="success">✅ SUCCESS</span></p>
    </div>
    
    <h2>📊 Artifacts</h2>
    <ul>
        <li><a href="pipeline-$DATE.log">Pipeline Log</a></li>
        <li><a href="../coverage/lcov-report/index.html">Coverage Report</a></li>
        <li><a href="npm-audit-$DATE.log">Security Audit</a></li>
    </ul>
    
    <h2>🔗 Quick Links</h2>
    <ul>
        <li><a href="http://localhost:9000" target="_blank">SonarQube</a></li>
    </ul>
</body>
</html>
EOF

echo -e "\033[34m📊 Pipeline report generated: $report_file\033[0m"

# Optional: Open report
read -p "Would you like to open the pipeline report? (y/N): " open_report
if [[ "$open_report" =~ ^[Yy]$ ]]; then
    if command -v xdg-open > /dev/null; then
        xdg-open "$report_file"
    elif command -v open > /dev/null; then
        open "$report_file"
    else
        echo "🌐 Please open $report_file manually in your browser"
    fi
    echo -e "\033[32m🌐 Opened pipeline report in your default browser\033[0m"
fi

echo -e "\033[32m🚀 Ready for deployment!\033[0m"