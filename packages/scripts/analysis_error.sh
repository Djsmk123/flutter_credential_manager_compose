#!/bin/bash

# Script to check for analysis errors in all packages
# Exit code: 0 if no errors, 1 if errors found

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$PACKAGES_DIR/.." && pwd)"

# Track if any errors were found
HAS_ERRORS=0
TOTAL_ERRORS=0
PACKAGES_CHECKED=0

echo "🔍 Checking for analysis errors in all packages..."
echo "📦 Packages directory: $PACKAGES_DIR"
echo ""

# Function to check a package
check_package() {
  local package_path="$1"
  local package_name=$(basename "$package_path")
  
  # Check if it's a Flutter package (has pubspec.yaml)
  if [ ! -f "$package_path/pubspec.yaml" ]; then
    return 0
  fi
  
  PACKAGES_CHECKED=$((PACKAGES_CHECKED + 1))
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 Checking: $package_name"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  cd "$package_path"
  
  # Run flutter analyze and capture output
  if flutter analyze --no-fatal-infos 2>&1 | tee /tmp/flutter_analyze_output.txt; then
    # Check if there are any errors (not just warnings/infos)
    if grep -q "error •" /tmp/flutter_analyze_output.txt; then
      echo -e "${RED}❌ Errors found in $package_name${NC}"
      ERROR_COUNT=$(grep -c "error •" /tmp/flutter_analyze_output.txt || echo "0")
      TOTAL_ERRORS=$((TOTAL_ERRORS + ERROR_COUNT))
      HAS_ERRORS=1
    else
      echo -e "${GREEN}✅ No errors in $package_name${NC}"
    fi
  else
    echo -e "${RED}❌ Analysis failed for $package_name${NC}"
    HAS_ERRORS=1
    TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
  fi
  
  echo ""
}

# Check each package directory
for package_dir in "$PACKAGES_DIR"/*; do
  if [ -d "$package_dir" ] && [ "$(basename "$package_dir")" != "scripts" ]; then
    check_package "$package_dir"
  fi
done

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Packages checked: $PACKAGES_CHECKED"
echo "Total errors: $TOTAL_ERRORS"

if [ $HAS_ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ All packages passed analysis!${NC}"
  exit 0
else
  echo -e "${RED}❌ Analysis found errors in one or more packages${NC}"
  exit 1
fi
