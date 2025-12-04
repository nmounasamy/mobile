#!/bin/bash

#############################################
# CONFIGURABLE EXPECTED VERSIONS
#############################################
EXPECTED_BREW="5.0.4"
EXPECTED_WATCHMAN="2023.12.04.00"
EXPECTED_XCODE="26.1.1"
EXPECTED_COCOAPODS="1.16.2"
EXPECTED_NVM="0.40.1"
EXPECTED_NODE="21.4.0"
EXPECTED_YARN="1.22.21"
EXPECTED_RUBY="3.2.2"

#############################################
# COLORS
#############################################
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # No Color

#############################################
# HELPERS
#############################################

# Compare versions: returns 0 if equal
compare_versions() {
  [ "$1" = "$2" ]
}

print_result(){
  name="$1"; installed="$2"; expected="$3"
  if [ -z "$installed" ]; then
    echo -e "$name: ${RED}not installed ✘${NC}"
  else
    if compare_versions "$installed" "$expected"; then
      echo -e "$name: $installed (expected $expected) ${GREEN}✔${NC}"
    else
      echo -e "$name: $installed (expected $expected) ${RED}✘ mismatch${NC}"
    fi
  fi
}

#############################################
# CHECKS
#############################################

# Brew
BREW_VERSION=$(brew --version 2>/dev/null | head -n 1 | awk '{print $2}')
print_result "Homebrew" "$BREW_VERSION" "$EXPECTED_BREW"

# Watchman
WATCHMAN_VERSION=$(watchman --version 2>/dev/null)
print_result "Watchman" "$WATCHMAN_VERSION" "$EXPECTED_WATCHMAN"

# Xcode – use `xcodebuild -version`
if command -v xcodebuild >/dev/null 2>&1; then
  XCODE_VERSION=$(xcodebuild -version 2>/dev/null | grep "Xcode" | awk '{print $2}')
else
  XCODE_VERSION=""
fi
print_result "Xcode" "$XCODE_VERSION" "$EXPECTED_XCODE"

# CocoaPods
COCOAPODS_VERSION=$(pod --version 2>/dev/null)
print_result "CocoaPods" "$COCOAPODS_VERSION" "$EXPECTED_COCOAPODS"

##############################################
# NVM — special handling (must be sourced)
#############################################
NVM_VERSION=""
NVM_DIR_CANDIDATES=()

# use existing env if present
[ -n "$NVM_DIR" ] && NVM_DIR_CANDIDATES+=("$NVM_DIR")
# common default
NVM_DIR_CANDIDATES+=("$HOME/.nvm")
# Homebrew locations (Intel + Apple Silicon)
NVM_DIR_CANDIDATES+=("/usr/local/opt/nvm")
NVM_DIR_CANDIDATES+=("/opt/homebrew/opt/nvm")

# find a candidate with nvm.sh
FOUND_NVM_SH=""
for d in "${NVM_DIR_CANDIDATES[@]}"; do
  if [ -d "$d" ] && [ -s "$d/nvm.sh" ]; then
    FOUND_NVM_SH="$d/nvm.sh"
    export NVM_DIR="$d"
    break
  fi
done

# If we found nvm.sh, source it in this script's shell then query
if [ -n "$FOUND_NVM_SH" ]; then
  # shellcheck disable=SC1090
  . "$FOUND_NVM_SH" >/dev/null 2>&1 || true
  if command -v nvm >/dev/null 2>&1; then
    NVM_VERSION=$(nvm --version 2>/dev/null)
  else
    # directory present but nvm not available after sourcing -> mark as not loaded
    NVM_VERSION="installed_but_not_loaded"
  fi
else
  # no nvm.sh; maybe user installed via other means or not at all
  NVM_VERSION=""
fi

# Normalize message
if [ "$NVM_VERSION" = "installed_but_not_loaded" ]; then
  echo "NVM: installed (nvm.sh found) but not usable in this shell ✘"
else
  # if empty -> not installed
  print_result "NVM" "$NVM_VERSION" "$EXPECTED_NVM"
fi

# Node
NODE_VERSION=$(node -v 2>/dev/null | sed 's/v//')
print_result "Node" "$NODE_VERSION" "$EXPECTED_NODE"

# Yarn
YARN_VERSION=$(yarn -v 2>/dev/null)
print_result "Yarn" "$YARN_VERSION" "$EXPECTED_YARN"

#############################################
# Ruby
#############################################
RUBY_VERSION=$(ruby -v 2>/dev/null | awk '{print $2}')
print_result "Ruby" "$RUBY_VERSION" "$EXPECTED_RUBY"


echo "Done."
