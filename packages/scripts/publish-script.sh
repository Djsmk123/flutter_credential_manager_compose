#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Package directories
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLATFORM_INTERFACE="$PACKAGES_DIR/credential_manager_platform_interface"
ANDROID="$PACKAGES_DIR/credential_manager_android"
IOS="$PACKAGES_DIR/credential_manager_ios"
MAIN="$PACKAGES_DIR/credential_manager"

# Function to print colored messages
print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

# Function to get package version
get_package_version() {
  local package_dir=$1
  if [ -f "$package_dir/pubspec.yaml" ]; then
    grep "^version:" "$package_dir/pubspec.yaml" | sed 's/version: //' | tr -d ' '
  else
    echo "unknown"
  fi
}

# Function to display package menu
show_menu() {
  clear
  echo "=========================================="
  echo "  Flutter Package Publisher"
  echo "=========================================="
  echo ""
  echo "Select a package to publish:"
  echo ""
  echo "  1) credential_manager_platform_interface (v$(get_package_version "$PLATFORM_INTERFACE"))"
  echo "  2) credential_manager_android (v$(get_package_version "$ANDROID"))"
  echo "  3) credential_manager_ios (v$(get_package_version "$IOS"))"
  echo "  4) credential_manager (v$(get_package_version "$MAIN"))"
  echo "  5) Publish all packages (in order)"
  echo "  0) Exit"
  echo ""
  echo -n "Enter your choice [0-5]: "
}

# Function to validate package directory
validate_package() {
  local package_dir=$1
  local package_name=$2

  if [ ! -d "$package_dir" ]; then
    print_error "Package directory not found: $package_dir"
    return 1
  fi

  if [ ! -f "$package_dir/pubspec.yaml" ]; then
    print_error "pubspec.yaml not found in $package_dir"
    return 1
  fi

  if [ ! -f "$package_dir/CHANGELOG.md" ]; then
    print_warning "CHANGELOG.md not found in $package_dir"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return 1
    fi
  fi

  if [ ! -f "$package_dir/LICENSE" ]; then
    print_warning "LICENSE file not found in $package_dir"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return 1
    fi
  fi

  return 0
}

# Function to publish a package
publish_package() {
  local package_dir=$1
  local package_name=$2
  local dry_run=$3

  print_info "Publishing $package_name..."
  print_info "Location: $package_dir"
  print_info "Version: $(get_package_version "$package_dir")"

  if [ ! -d "$package_dir" ]; then
    print_error "Package directory not found: $package_dir"
    return 1
  fi

  cd "$package_dir" || return 1

  # Validate package
  if ! validate_package "$package_dir" "$package_name"; then
    return 1
  fi

  # Check for uncommitted changes
  if [ -d ".git" ]; then
    if ! git diff-index --quiet HEAD --; then
      print_warning "You have uncommitted changes in $package_name"
      read -p "Continue anyway? (y/N): " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
      fi
    fi
  fi

  # Run flutter pub get first
  print_info "Running 'flutter pub get'..."
  if ! flutter pub get; then
    print_error "Failed to run 'flutter pub get'"
    return 1
  fi

  # Run flutter analyze
  print_info "Running 'flutter analyze'..."
  if ! flutter analyze; then
    print_warning "Flutter analyze found issues"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return 1
    fi
  fi

  # Publish command
  if [ "$dry_run" = true ]; then
    print_info "Running DRY RUN publish..."
    if flutter pub publish --dry-run; then
      print_success "Dry run completed successfully for $package_name"
      return 0
    else
      print_error "Dry run failed for $package_name"
      return 1
    fi
  else
    print_warning "This will PUBLISH $package_name to pub.dev"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_info "Publish cancelled"
      return 1
    fi

    print_info "Publishing $package_name to pub.dev..."
    if flutter pub publish; then
      print_success "Successfully published $package_name!"
      return 0
    else
      print_error "Failed to publish $package_name"
      return 1
    fi
  fi
}

# Main script
main() {
  local dry_run=false

  # Parse command line arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --dry-run)
        dry_run=true
        shift
        ;;
      -h|--help)
        echo "Usage: $0 [--dry-run]"
        echo ""
        echo "Options:"
        echo "  --dry-run    Run in dry-run mode (no actual publishing)"
        echo "  -h, --help   Show this help message"
        exit 0
        ;;
      *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
    esac
  done

  if [ "$dry_run" = true ]; then
    print_info "Running in DRY RUN mode - no packages will be published"
  fi

  while true; do
    show_menu
    read -r choice

    case $choice in
      1)
        publish_package "$PLATFORM_INTERFACE" "credential_manager_platform_interface" "$dry_run"
        ;;
      2)
        publish_package "$ANDROID" "credential_manager_android" "$dry_run"
        ;;
      3)
        publish_package "$IOS" "credential_manager_ios" "$dry_run"
        ;;
      4)
        publish_package "$MAIN" "credential_manager" "$dry_run"
        ;;
      5)
        print_info "Publishing all packages in order..."
        print_warning "Recommended order: platform_interface -> android -> ios -> main"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          publish_package "$PLATFORM_INTERFACE" "credential_manager_platform_interface" "$dry_run" && \
          publish_package "$ANDROID" "credential_manager_android" "$dry_run" && \
          publish_package "$IOS" "credential_manager_ios" "$dry_run" && \
          publish_package "$MAIN" "credential_manager" "$dry_run" && \
          print_success "All packages published successfully!"
        fi
        ;;
      0)
        print_info "Exiting..."
        exit 0
        ;;
      *)
        print_error "Invalid choice. Please enter a number between 0-5."
        sleep 2
        ;;
    esac

    if [ "$choice" != "0" ] && [ "$choice" != "5" ]; then
      echo ""
      read -p "Press Enter to continue..."
    fi
  done
}

# Run main function
main "$@"

