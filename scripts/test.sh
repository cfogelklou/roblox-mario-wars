#!/bin/bash
# test.sh - Local CI test script
# This script runs the same checks that GitHub Actions runs in CI
# Run this before committing to ensure your changes will pass CI

set -e  # Exit on first error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track if any tests fail
FAILED=0

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         Running Local CI Tests for Mario Wars             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Function to print section headers
print_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
print_section "Checking for required tools..."

MISSING_TOOLS=()

if ! command_exists stylua; then
    MISSING_TOOLS+=("stylua")
fi

if ! command_exists selene; then
    MISSING_TOOLS+=("selene")
fi

if ! command_exists rojo; then
    MISSING_TOOLS+=("rojo")
fi

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo -e "${RED}✗ Missing required tools: ${MISSING_TOOLS[*]}${NC}"
    echo ""
    echo "Please install missing tools using aftman:"
    echo "  aftman install"
    echo ""
    echo "Or install aftman first from: https://github.com/LPGhatguy/aftman"
    exit 1
fi

echo -e "${GREEN}✓ All required tools found${NC}"

# Test 1: Code Formatting Check
print_section "Test 1: Code Formatting (StyLua)"

if stylua --check src tests; then
    echo -e "${GREEN}✓ Code formatting check passed${NC}"
else
    echo -e "${RED}✗ Code formatting check failed${NC}"
    echo ""
    echo "Fix by running: stylua src tests"
    FAILED=1
fi

# Test 2: Linting
print_section "Test 2: Linting (Selene)"

if selene src tests; then
    echo -e "${GREEN}✓ Linting passed${NC}"
else
    echo -e "${RED}✗ Linting failed${NC}"
    echo ""
    echo "Review the errors above and fix any issues in your code"
    FAILED=1
fi

# Test 3: Rojo Project Structure
print_section "Test 3: Rojo Project Structure"

if rojo sourcemap default.project.json --output sourcemap.json 2>&1; then
    echo -e "${GREEN}✓ Rojo project structure is valid${NC}"
    # Clean up sourcemap file
    rm -f sourcemap.json
else
    echo -e "${RED}✗ Rojo project structure validation failed${NC}"
    FAILED=1
fi

# Test 4: Build Project
print_section "Test 4: Build Roblox Place File"

if rojo build default.project.json --output MarioWars.rbxl 2>&1; then
    echo -e "${GREEN}✓ Successfully built MarioWars.rbxl${NC}"
    # Clean up build file (optional - comment out if you want to keep it)
    rm -f MarioWars.rbxl
else
    echo -e "${RED}✗ Build failed${NC}"
    FAILED=1
fi

# Summary
print_section "Test Summary"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                  ✓ ALL TESTS PASSED ✓                     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Your code is ready to commit and push!"
    echo ""
    exit 0
else
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                  ✗ SOME TESTS FAILED ✗                    ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Please fix the errors above before committing."
    echo ""
    echo "Quick fixes:"
    echo "  • Format code: stylua src tests"
    echo "  • Check linting: selene src tests"
    echo "  • Verify project: rojo sourcemap default.project.json"
    echo ""
    exit 1
fi
