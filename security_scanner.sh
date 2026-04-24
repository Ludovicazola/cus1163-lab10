#!/bin/bash

#####################################################
# Lab 10: File Permission Security Scanner
# Description: Find files with insecure permissions
#####################################################

# Configuration
TEST_DIR="./test_files"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

#####################################################
# Setup Function (FULLY PROVIDED - DO NOT MODIFY)
#####################################################

setup_test_environment() {
    echo "Setting up test environment..."

    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"/{web,config,scripts,data,uploads}

    touch "$TEST_DIR/web/index.html"
    chmod 777 "$TEST_DIR/web/index.html"

    touch "$TEST_DIR/web/style.css"
    chmod 755 "$TEST_DIR/web/style.css"

    touch "$TEST_DIR/web/script.js"
    chmod 644 "$TEST_DIR/web/script.js"

    touch "$TEST_DIR/config/database.conf"
    chmod 666 "$TEST_DIR/config/database.conf"

    touch "$TEST_DIR/config/api_keys.conf"
    chmod 644 "$TEST_DIR/config/api_keys.conf"

    touch "$TEST_DIR/config/settings.conf"
    chmod 755 "$TEST_DIR/config/settings.conf"

    echo "#!/bin/bash" > "$TEST_DIR/scripts/deploy.sh"
    chmod 755 "$TEST_DIR/scripts/deploy.sh"

    echo "#!/bin/bash" > "$TEST_DIR/scripts/backup.sh"
    chmod 777 "$TEST_DIR/scripts/backup.sh"

    touch "$TEST_DIR/data/users.txt"
    chmod 666 "$TEST_DIR/data/users.txt"

    touch "$TEST_DIR/data/logs.txt"
    chmod 640 "$TEST_DIR/data/logs.txt"

    chmod 777 "$TEST_DIR/uploads"

    echo "Test files created in: $TEST_DIR"
    echo ""
}

#####################################################
# TODO SECTIONS - IMPLEMENT THESE
#####################################################

find_world_writable() {
    echo "--- World-Writable Files & Directories ---"

    local count=0

    while IFS= read -r item; do
        perms=$(stat -c "%a" "$item")

        if [ -f "$item" ]; then
            echo -e "${RED}[FILE]${NC} $item ($perms)"
        elif [ -d "$item" ]; then
            echo -e "${RED}[DIR] ${NC} $item ($perms)"
        fi

        ((count++))
    done < <(find "$TEST_DIR" -perm /o+w)

    echo "Found $count world-writable items"
    echo ""
    return $count
}

find_executable_non_scripts() {
    echo "--- Executable Non-Script Files ---"

    local count=0

    while IFS= read -r file; do
        perms=$(stat -c "%a" "$file")
        echo -e "${YELLOW}[EXEC]${NC} $file ($perms)"
        ((count++))
    done < <(find "$TEST_DIR" -type f \( -name "*.html" -o -name "*.css" -o -name "*.txt" -o -name "*.conf" \) -perm /111)


    echo ""
    echo "Found $count files that shouldn't be executable"
    echo ""
    return $count
}

#####################################################
# Main Execution (FULLY PROVIDED - DO NOT MODIFY)
#####################################################

main() {
    echo "========================================"
    echo "File Permission Security Scanner"
    echo "========================================"

    setup_test_environment

    echo "========================================"
    echo "Scanning for INSECURE Files/Directories"
    echo "========================================"
    echo ""

    find_world_writable
    world_writable_count=$?

    find_executable_non_scripts
    executable_count=$?

    total_issues=$((world_writable_count + executable_count))

    echo "========================================"
    echo "Security Scan Complete"
    echo "========================================"
    echo "Summary:"
    echo "- World-writable items found: $world_writable_count"
    echo "- Improperly executable files found: $executable_count"
    echo "- Total security issues: $total_issues"
    echo ""

    if [ $total_issues -gt 0 ]; then
        echo -e "${RED}⚠️  SECURITY ALERT: $total_issues permission vulnerabilities detected!${NC}"
        echo "These files need immediate attention."
    else
        echo -e "${GREEN}✓ No security issues found. All permissions are secure.${NC}"
    fi

    echo "========================================"
}

main
