#!/usr/bin/env bash
# Environment checker using JSON config
# Prints colored ✔/✘ and suggests fixes on mismatch

CONFIG_FILE="expected_versions.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required. Install with 'brew install jq'"
  exit 1
fi

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

compare_versions(){ [ "$1" = "$2" ]; }

print_result(){
  name="$1"; installed="$2"; expected="$3"; suggestion="$4"

  if [ -z "$installed" ]; then
    echo -e "$name: ${RED}not installed ✘${NC}"
    [ -n "$suggestion" ] && echo "  → ${suggestion}"
  else
    if compare_versions "$installed" "$expected"; then
      echo -e "$name: $installed (expected $expected) ${GREEN}✔${NC}"
    else
      echo -e "$name: $installed (expected $expected) ${RED}✘ mismatch${NC}"
      [ -n "$suggestion" ] && echo "  → ${suggestion}"
    fi
  fi
}

# Load expected versions from JSON
EXPECTED_BREW=$(jq -r '.brew' "$CONFIG_FILE")
EXPECTED_WATCHMAN=$(jq -r '.watchman' "$CONFIG_FILE")
EXPECTED_XCODE=$(jq -r '.xcode' "$CONFIG_FILE")
EXPECTED_COCOAPODS=$(jq -r '.cocoapods' "$CONFIG_FILE")
EXPECTED_NVM=$(jq -r '.nvm' "$CONFIG_FILE")
EXPECTED_NODE=$(jq -r '.node' "$CONFIG_FILE")
EXPECTED_YARN=$(jq -r '.yarn' "$CONFIG_FILE")
EXPECTED_RUBY=$(jq -r '.ruby' "$CONFIG_FILE")

# ---- Checks with suggestions ----

# Homebrew
BREW_VERSION=$(brew --version 2>/dev/null | head -n1 | awk '{print $2}')
print_result "Homebrew" "$BREW_VERSION" "$EXPECTED_BREW" "Install/update: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""

# Watchman
WATCHMAN_VERSION=$(watchman --version 2>/dev/null)
print_result "Watchman" "$WATCHMAN_VERSION" "$EXPECTED_WATCHMAN" "brew install watchman"

# Xcode
if command -v xcodebuild >/dev/null 2>&1; then
  XCODE_VERSION=$(xcodebuild -version 2>/dev/null | awk '/Xcode/ {print $2}')
else
  XCODE_VERSION=""
fi
print_result "Xcode" "$XCODE_VERSION" "$EXPECTED_XCODE" "Download from App Store or https://apps.apple.com/us/app/xcode/id497799835"

# CocoaPods
COCOAPODS_VERSION=$(pod --version 2>/dev/null)
print_result "CocoaPods" "$COCOAPODS_VERSION" "$EXPECTED_COCOAPODS" "sudo gem install cocoapods"

# NVM
NVM_VERSION=""
NVM_DIR_CANDIDATES=()
[ -n "$NVM_DIR" ] && NVM_DIR_CANDIDATES+=("$NVM_DIR")
NVM_DIR_CANDIDATES+=("$HOME/.nvm" "/usr/local/opt/nvm" "/opt/homebrew/opt/nvm")
FOUND_NVM_SH=""
for d in "${NVM_DIR_CANDIDATES[@]}"; do
  if [ -d "$d" ] && [ -s "$d/nvm.sh" ]; then
    FOUND_NVM_SH="$d/nvm.sh"
    export NVM_DIR="$d"
    break
  fi
done
if [ -n "$FOUND_NVM_SH" ]; then
  . "$FOUND_NVM_SH" >/dev/null 2>&1 || true
  if command -v nvm >/dev/null 2>&1; then
    NVM_VERSION=$(nvm --version 2>/dev/null)
  else
    NVM_VERSION="installed_but_not_loaded"
  fi
else
  NVM_VERSION=""
fi
if [ "$NVM_VERSION" = "installed_but_not_loaded" ]; then
  echo -e "NVM: installed (nvm.sh found) but not usable in this shell ${RED}✘${NC}"
  echo "  → Ensure .nvm/nvm.sh is sourced in your shell startup (~/.zshrc or ~/.bashrc)"
else
  print_result "NVM" "$NVM_VERSION" "$EXPECTED_NVM" "Install: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
fi

# Node
NODE_VERSION=$(node -v 2>/dev/null | sed 's/^v//')
print_result "Node" "$NODE_VERSION" "$EXPECTED_NODE" "Use 'nvm install $EXPECTED_NODE' and 'nvm use $EXPECTED_NODE'"

# Yarn
YARN_VERSION=$(yarn -v 2>/dev/null)
print_result "Yarn" "$YARN_VERSION" "$EXPECTED_YARN" "brew install yarn"

# Ruby
RUBY_VERSION=$(ruby -v 2>/dev/null | awk '{print $2}')
print_result "Ruby" "$RUBY_VERSION" "$EXPECTED_RUBY" "Install: brew install ruby or use rbenv/rvm"

echo "Done."
