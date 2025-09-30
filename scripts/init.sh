#!/bin/bash

# Claude Code Ecosystem - Initialization and Validation Script
# Validates all dependencies required for the .claude/ configuration system
# Does NOT install anything - only validates and guides user

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_VERSION="1.0.0"
MIN_PYTHON_VERSION="3.8"
MIN_NODE_VERSION="18"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status counters
CRITICAL_MISSING=0
ESSENTIAL_MISSING=0
RECOMMENDED_MISSING=0

# Missing items arrays
declare -a CRITICAL_ITEMS=()
declare -a ESSENTIAL_ITEMS=()
declare -a RECOMMENDED_ITEMS=()

# ═══════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

print_header() {
	echo ""
	echo "════════════════════════════════════════════════════════════════"
	echo "  Claude Code Ecosystem - Initialization Check v${SCRIPT_VERSION}"
	echo "════════════════════════════════════════════════════════════════"
	echo ""
}

print_section() {
	echo ""
	echo -e "${BLUE}▶ $1${NC}"
	echo "────────────────────────────────────────────────────────────────"
}

check_command() {
	if command -v "$1" &>/dev/null; then
		echo -e "${GREEN}✓${NC} $2"
		return 0
	else
		echo -e "${RED}✗${NC} $2"
		return 1
	fi
}

check_python_version() {
	if ! command -v python3 &>/dev/null; then
		return 1
	fi

	local version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
	local required="$MIN_PYTHON_VERSION"

	# Use Python's native tuple comparison (more robust than bash string parsing)
	if python3 -c "import sys; req_ver = tuple(map(int, '$required'.split('.'))); sys.exit(0 if sys.version_info[:2] >= req_ver else 1)"; then
		echo -e "${GREEN}✓${NC} Python $version (>= $required required)"
		return 0
	else
		echo -e "${RED}✗${NC} Python $version (>= $required required)"
		return 1
	fi
}

check_node_version() {
	if ! command -v node &>/dev/null; then
		return 1
	fi

	local version=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)

	if [ "$version" -ge "$MIN_NODE_VERSION" ]; then
		echo -e "${GREEN}✓${NC} Node.js v$version (>= v$MIN_NODE_VERSION required)"
		return 0
	else
		echo -e "${RED}✗${NC} Node.js v$version (>= v$MIN_NODE_VERSION required)"
		return 1
	fi
}

check_gh_auth() {
	if ! command -v gh &>/dev/null; then
		return 1
	fi

	if gh auth status &>/dev/null; then
		echo -e "${GREEN}✓${NC} GitHub CLI (authenticated)"
		return 0
	else
		echo -e "${YELLOW}⚠${NC} GitHub CLI (not authenticated - run: gh auth login)"
		return 1
	fi
}

# ═══════════════════════════════════════════════════════════════════════════
# VALIDATION PHASES
# ═══════════════════════════════════════════════════════════════════════════

validate_critical_dependencies() {
	print_section "CRITICAL Dependencies (Blockers)"

	if ! check_command claude "Claude Code CLI"; then
		CRITICAL_MISSING=$((CRITICAL_MISSING + 1))
		CRITICAL_ITEMS+=("Claude Code CLI|https://docs.anthropic.com/en/docs/claude-code/installation")
	fi

	if ! check_command git "Git"; then
		CRITICAL_MISSING=$((CRITICAL_MISSING + 1))
		CRITICAL_ITEMS+=("Git|https://git-scm.com/downloads")
	fi

	if ! check_python_version; then
		CRITICAL_MISSING=$((CRITICAL_MISSING + 1))
		CRITICAL_ITEMS+=("Python 3.8+|https://www.python.org/downloads/")
	fi
}

validate_essential_dependencies() {
	print_section "ESSENTIAL Dependencies (Full Functionality)"

	if ! check_gh_auth; then
		ESSENTIAL_MISSING=$((ESSENTIAL_MISSING + 1))
		ESSENTIAL_ITEMS+=("GitHub CLI|https://cli.github.com/")
	fi

	if ! check_node_version; then
		ESSENTIAL_MISSING=$((ESSENTIAL_MISSING + 1))
		ESSENTIAL_ITEMS+=("Node.js 18+|https://nodejs.org/")
	else
		if ! command -v npx &>/dev/null; then
			echo -e "${RED}✗${NC} npx (should come with Node.js)"
			ESSENTIAL_MISSING=$((ESSENTIAL_MISSING + 1))
			ESSENTIAL_ITEMS+=("npx|https://nodejs.org/")
		else
			echo -e "${GREEN}✓${NC} npx"
		fi
	fi

	# Notification system (platform-specific)
	if [[ "$OSTYPE" == "darwin"* ]]; then
		if ! check_command terminal-notifier "terminal-notifier (macOS notifications)"; then
			ESSENTIAL_MISSING=$((ESSENTIAL_MISSING + 1))
			ESSENTIAL_ITEMS+=("terminal-notifier|https://github.com/julienXX/terminal-notifier#install")
		fi
	elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
		if ! check_command notify-send "notify-send (Linux notifications)"; then
			ESSENTIAL_MISSING=$((ESSENTIAL_MISSING + 1))
			ESSENTIAL_ITEMS+=("notify-send|https://wiki.archlinux.org/title/Desktop_notifications")
		fi
	fi

	# Code formatters
	if command -v npx &>/dev/null; then
		if npx prettier --version &>/dev/null; then
			echo -e "${GREEN}✓${NC} Prettier (JS/TS/JSON/YAML formatter)"
		else
			echo -e "${YELLOW}⚠${NC} Prettier (will auto-install on first use via npx)"
		fi
	fi

	if ! check_command black "Black (Python formatter)"; then
		ESSENTIAL_MISSING=$((ESSENTIAL_MISSING + 1))
		ESSENTIAL_ITEMS+=("Black|https://black.readthedocs.io/en/stable/getting_started.html")
	fi

	# Additional Python formatters (optional but recommended)
	if command -v python3 &>/dev/null; then
		if python3 -m ruff --version &>/dev/null 2>&1; then
			echo -e "${GREEN}✓${NC} Ruff (Python linter/formatter)"
		else
			echo -e "${YELLOW}⚠${NC} Ruff (Python linter/formatter - recommended)"
		fi

		if python3 -m autopep8 --version &>/dev/null 2>&1; then
			echo -e "${GREEN}✓${NC} autopep8 (Python formatter)"
		else
			echo -e "${YELLOW}⚠${NC} autopep8 (Python formatter - optional)"
		fi
	fi

	# ESLint check (optional for JS/TS projects)
	if command -v npx &>/dev/null; then
		if npx eslint --version &>/dev/null 2>&1; then
			echo -e "${GREEN}✓${NC} ESLint (JS/TS linter - optional)"
		else
			echo -e "${YELLOW}⚠${NC} ESLint (JS/TS linter - optional, install if needed)"
		fi
	fi

	# MCP Servers configuration
	if [ -f ".mcp.json" ]; then
		echo -e "${GREEN}✓${NC} MCP Servers configured (.mcp.json exists)"

		# Validate JSON syntax if jq is available
		if command -v jq &>/dev/null; then
			if jq empty .mcp.json 2>/dev/null; then
				echo "  → Valid JSON syntax"
			else
				echo -e "  ${YELLOW}⚠${NC} Invalid JSON syntax - check .mcp.json"
			fi
		fi
	else
		echo -e "${RED}✗${NC} MCP Servers (.mcp.json not found)"
		echo "  → Copy template: cp .mcp.json.example .mcp.json"
		ESSENTIAL_MISSING=$((ESSENTIAL_MISSING + 1))
		ESSENTIAL_ITEMS+=("MCP Servers (copy .mcp.json.example)|https://github.com/modelcontextprotocol/servers")
	fi
}

validate_recommended_dependencies() {
	print_section "RECOMMENDED Dependencies (Enhanced Experience)"

	if ! check_command shfmt "shfmt (Bash formatter)"; then
		RECOMMENDED_MISSING=$((RECOMMENDED_MISSING + 1))
		RECOMMENDED_ITEMS+=("shfmt|https://github.com/mvdan/sh#shfmt")
	fi

	if ! check_command jq "jq (JSON processor)"; then
		RECOMMENDED_MISSING=$((RECOMMENDED_MISSING + 1))
		RECOMMENDED_ITEMS+=("jq|https://jqlang.github.io/jq/download/")
	fi
}

validate_optional_features() {
	print_section "OPTIONAL Features (Specific Use Cases)"

	echo "Additional MCP servers available at:"
	echo "  → https://github.com/modelcontextprotocol/servers"
	echo ""
	echo "Configured servers (in .mcp.json):"
	echo "  • Playwright: Web testing & automation"
	echo "  • Shadcn: UI component development"
}

# ═══════════════════════════════════════════════════════════════════════════
# REPORTING & ASSISTANCE
# ═══════════════════════════════════════════════════════════════════════════

print_summary() {
	echo ""
	echo "════════════════════════════════════════════════════════════════"
	echo "  VALIDATION SUMMARY"
	echo "════════════════════════════════════════════════════════════════"

	if [ $CRITICAL_MISSING -eq 0 ] && [ $ESSENTIAL_MISSING -eq 0 ]; then
		echo -e "${GREEN}✓ All critical and essential dependencies are installed!${NC}"

		if [ $RECOMMENDED_MISSING -gt 0 ]; then
			echo -e "${YELLOW}⚠ ${RECOMMENDED_MISSING} recommended dependencies missing${NC}"
		else
			echo -e "${GREEN}✓ All recommended dependencies installed!${NC}"
		fi

		echo ""
		echo "Your Claude Code ecosystem is ready to use! 🚀"
		return 0
	else
		if [ $CRITICAL_MISSING -gt 0 ]; then
			echo -e "${RED}✗ ${CRITICAL_MISSING} CRITICAL dependencies missing${NC}"
		fi

		if [ $ESSENTIAL_MISSING -gt 0 ]; then
			echo -e "${YELLOW}⚠ ${ESSENTIAL_MISSING} ESSENTIAL dependencies missing${NC}"
		fi

		if [ $RECOMMENDED_MISSING -gt 0 ]; then
			echo -e "${BLUE}ℹ ${RECOMMENDED_MISSING} RECOMMENDED dependencies missing${NC}"
		fi

		return 1
	fi
}

print_installation_guide() {
	if [ $CRITICAL_MISSING -eq 0 ] && [ $ESSENTIAL_MISSING -eq 0 ]; then
		return
	fi

	echo ""
	echo "════════════════════════════════════════════════════════════════"
	echo "  INSTALLATION GUIDE"
	echo "════════════════════════════════════════════════════════════════"
	echo ""

	if [ ${#CRITICAL_ITEMS[@]} -gt 0 ]; then
		echo -e "${RED}CRITICAL (must install):${NC}"
		for item in "${CRITICAL_ITEMS[@]}"; do
			IFS='|' read -r name url <<<"$item"
			echo "  • $name"
			echo "    📖 $url"
		done
		echo ""
	fi

	if [ ${#ESSENTIAL_ITEMS[@]} -gt 0 ]; then
		echo -e "${YELLOW}ESSENTIAL (strongly recommended):${NC}"
		for item in "${ESSENTIAL_ITEMS[@]}"; do
			IFS='|' read -r name url <<<"$item"
			echo "  • $name"
			echo "    📖 $url"
		done
		echo ""
	fi

	if [ ${#RECOMMENDED_ITEMS[@]} -gt 0 ]; then
		echo -e "${BLUE}RECOMMENDED (enhanced experience):${NC}"
		for item in "${RECOMMENDED_ITEMS[@]}"; do
			IFS='|' read -r name url <<<"$item"
			echo "  • $name"
			echo "    📖 $url"
		done
		echo ""
	fi
}

offer_assistance() {
	if [ $CRITICAL_MISSING -eq 0 ] && [ $ESSENTIAL_MISSING -eq 0 ]; then
		return
	fi

	echo "════════════════════════════════════════════════════════════════"
	echo "  NEED HELP?"
	echo "════════════════════════════════════════════════════════════════"
	echo ""
	echo "Option 1: Claude Code Assistant"
	echo "  → Type: 'claude' and ask for installation help"
	echo "  → Example: 'Help me install the missing dependencies'"
	echo ""
	echo "Option 2: Manual Installation"
	echo "  → Follow the documentation links above"
	echo "  → Run this script again after installation: ./scripts/init.sh"
	echo ""

	if [ $CRITICAL_MISSING -gt 0 ]; then
		echo -e "${RED}⚠ IMPORTANT: Cannot proceed without CRITICAL dependencies${NC}"
	fi
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════════════════

main() {
	print_header

	validate_critical_dependencies
	validate_essential_dependencies
	validate_recommended_dependencies
	validate_optional_features

	print_summary
	print_installation_guide
	offer_assistance

	echo ""

	# Exit code reflects validation status
	if [ $CRITICAL_MISSING -gt 0 ]; then
		exit 2 # Critical failures
	elif [ $ESSENTIAL_MISSING -gt 0 ]; then
		exit 1 # Essential failures
	else
		exit 0 # Success
	fi
}

main "$@"
