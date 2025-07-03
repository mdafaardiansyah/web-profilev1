#!/bin/bash
# Trivy Security Scan Script for Linux/Unix
# This script performs comprehensive security scanning using Trivy

# Parse command line arguments
IMAGE_NAME="ardidafa/portfolio:latest"
REPORT_DIR="./security-reports"
SEVERITY="HIGH,CRITICAL"

while [[ $# -gt 0 ]]; do
    case $1 in
        --image-name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        --report-dir)
            REPORT_DIR="$2"
            shift 2
            ;;
        --severity)
            SEVERITY="$2"
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
TRIVY_CACHE_DIR="$HOME/.cache/trivy"

echo -e "\033[34m🔒 Starting Trivy Security Scan...\033[0m"
echo -e "\033[34m📅 Scan Date: $(date)\033[0m"
echo -e "\033[34m🎯 Target Image: $IMAGE_NAME\033[0m"
echo ""

# Create reports directory
if [ ! -d "$REPORT_DIR" ]; then
    mkdir -p "$REPORT_DIR"
fi
if [ ! -d "$TRIVY_CACHE_DIR" ]; then
    mkdir -p "$TRIVY_CACHE_DIR"
fi

# Check if Trivy is installed
if ! command -v trivy >/dev/null 2>&1; then
    echo -e "\033[33m⚠️  Trivy not found. Installing Trivy...\033[0m"
    
    # Detect OS and install accordingly
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    fi
    
    case "$OS" in
        *"Ubuntu"*|*"Debian"*)
            echo -e "\033[33m📦 Installing Trivy for Ubuntu/Debian...\033[0m"
            sudo apt-get update
            sudo apt-get install -y wget apt-transport-https gnupg lsb-release
            wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
            echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
            sudo apt-get update
            sudo apt-get install -y trivy
            ;;
        *"CentOS"*|*"Red Hat"*|*"RHEL"*)
            echo -e "\033[33m📦 Installing Trivy for CentOS/RHEL...\033[0m"
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://aquasecurity.github.io/trivy-repo/rpm/releases.repo
            sudo yum install -y trivy
            ;;
        *"Fedora"*)
            echo -e "\033[33m📦 Installing Trivy for Fedora...\033[0m"
            sudo dnf install -y dnf-plugins-core
            sudo dnf config-manager --add-repo https://aquasecurity.github.io/trivy-repo/rpm/releases.repo
            sudo dnf install -y trivy
            ;;
        *)
            echo -e "\033[31m❌ Unsupported OS. Please install Trivy manually from:\033[0m"
            echo -e "\033[37m   https://github.com/aquasecurity/trivy/releases\033[0m"
            exit 1
            ;;
    esac
    
    # Verify installation
    if ! command -v trivy >/dev/null 2>&1; then
        echo -e "\033[31m❌ Failed to install Trivy. Please install manually.\033[0m"
        exit 1
    fi
fi

echo -e "\033[32m✅ Trivy is available\033[0m"

# Update Trivy database
echo -e "\033[33m📡 Updating Trivy vulnerability database...\033[0m"
trivy image --download-db-only --cache-dir "$TRIVY_CACHE_DIR"

# Function to run Trivy scan
invoke_trivy_scan() {
    local scan_type="$1"
    local target="$2"
    local output_file="$3"
    local severity_level="$4"
    
    echo -e "\033[34m🔍 Running $scan_type scan...\033[0m"
    
    # Table format report
    trivy "$scan_type" \
        --cache-dir "$TRIVY_CACHE_DIR" \
        --severity "$severity_level" \
        --format table \
        --output "$output_file" \
        "$target"
    
    # JSON format report for CI/CD integration
    local json_file="${output_file%.txt}.json"
    trivy "$scan_type" \
        --cache-dir "$TRIVY_CACHE_DIR" \
        --severity "$severity_level" \
        --format json \
        --output "$json_file" \
        "$target"
    
    echo "$json_file"
}

# 1. Scan Docker Image
echo -e "\033[34m🐳 Scanning Docker Image: $IMAGE_NAME\033[0m"
image_json_file=$(invoke_trivy_scan "image" "$IMAGE_NAME" "$REPORT_DIR/image-scan-$DATE.txt" "$SEVERITY")

# 2. Scan Filesystem (source code)
echo -e "\033[34m📁 Scanning Filesystem (source code)...\033[0m"
fs_json_file=$(invoke_trivy_scan "fs" "." "$REPORT_DIR/filesystem-scan-$DATE.txt" "$SEVERITY")

# 3. Scan package.json for vulnerabilities
if [ -f "package.json" ]; then
    echo -e "\033[34m📦 Scanning package.json dependencies...\033[0m"
    dep_json_file=$(invoke_trivy_scan "fs" "package.json" "$REPORT_DIR/dependencies-scan-$DATE.txt" "MEDIUM,HIGH,CRITICAL")
fi

# 4. Generate summary report
echo -e "\033[34m📊 Generating summary report...\033[0m"
SUMMARY_FILE="$REPORT_DIR/security-summary-$DATE.txt"

cat > "$SUMMARY_FILE" << EOF
===========================================
TRIVY SECURITY SCAN SUMMARY
===========================================
Scan Date: $(date)
Target Image: $IMAGE_NAME
Scanned by: $(whoami)
Host: $(hostname)

===========================================
SCAN RESULTS OVERVIEW
===========================================

Image Scan Results:
EOF

# Count vulnerabilities in image scan
if [ -f "$image_json_file" ]; then
    if command -v jq >/dev/null 2>&1; then
        critical_count=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$image_json_file" 2>/dev/null || echo "0")
        high_count=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' "$image_json_file" 2>/dev/null || echo "0")
        
        echo "  - Critical vulnerabilities: $critical_count" >> "$SUMMARY_FILE"
        echo "  - High vulnerabilities: $high_count" >> "$SUMMARY_FILE"
    else
        echo "  - Unable to parse vulnerability counts (jq not available)" >> "$SUMMARY_FILE"
    fi
fi

echo "" >> "$SUMMARY_FILE"
echo "Filesystem Scan Results:" >> "$SUMMARY_FILE"

# Count vulnerabilities in filesystem scan
if [ -f "$fs_json_file" ]; then
    if command -v jq >/dev/null 2>&1; then
        fs_critical_count=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$fs_json_file" 2>/dev/null || echo "0")
        fs_high_count=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' "$fs_json_file" 2>/dev/null || echo "0")
        
        echo "  - Critical vulnerabilities: $fs_critical_count" >> "$SUMMARY_FILE"
        echo "  - High vulnerabilities: $fs_high_count" >> "$SUMMARY_FILE"
    else
        echo "  - Unable to parse vulnerability counts (jq not available)" >> "$SUMMARY_FILE"
    fi
fi

cat >> "$SUMMARY_FILE" << EOF

===========================================
RECOMMENDATIONS
===========================================
1. Review all CRITICAL and HIGH severity vulnerabilities
2. Update vulnerable packages to latest secure versions
3. Consider using distroless or minimal base images
4. Implement regular security scanning in CI/CD pipeline
5. Monitor security advisories for used dependencies

Report files generated in: $REPORT_DIR/
EOF

# Display results
echo ""
echo -e "\033[32m✅ Security scan completed!\033[0m"
echo ""
echo -e "\033[34m📋 Generated Reports:\033[0m"
ls -la "$REPORT_DIR"/*"$DATE"* 2>/dev/null || echo "No reports found"
echo ""
echo -e "\033[34m📊 Summary Report:\033[0m"
cat "$SUMMARY_FILE"

# Check if there are critical vulnerabilities
if [ -f "$image_json_file" ] && command -v jq >/dev/null 2>&1; then
    total_critical=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$image_json_file" 2>/dev/null || echo "0")
    
    if [ "$total_critical" -gt 0 ]; then
        echo ""
        echo -e "\033[31m⚠️  WARNING: $total_critical CRITICAL vulnerabilities found!\033[0m"
        echo -e "\033[31m🚨 Immediate action required!\033[0m"
        exit 1
    else
        echo ""
        echo -e "\033[32m🎉 No critical vulnerabilities found!\033[0m"
    fi
else
    echo -e "\033[33m⚠️  Unable to determine critical vulnerability count\033[0m"
fi

echo ""
echo -e "\033[34m🔗 For detailed analysis, review the generated report files.\033[0m"
echo -e "\033[34m📚 Trivy documentation: https://trivy.dev/\033[0m"

# Optional: Open reports folder
read -p "Would you like to open the reports folder? (y/N): " open_folder
if [[ "$open_folder" =~ ^[Yy]$ ]]; then
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$REPORT_DIR"
    elif command -v open >/dev/null 2>&1; then
        open "$REPORT_DIR"
    else
        echo "📁 Please open $REPORT_DIR manually"
    fi
    echo -e "\033[32m📁 Opened reports folder\033[0m"
fi