#!/usr/bin/env sh
set -eu

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install from https://brew.sh and re-run."
  exit 1
fi

if [ -f "$(dirname -- "$0")/../Brewfile" ]; then
  brew bundle --file="$(dirname -- "$0")/../Brewfile"
fi

# Claude Code is installed with Anthropic's user-level installer. Codex,
# OpenCode, and GitHub Copilot CLI are managed by the Brewfile.
# shellcheck disable=SC1091
. "$(dirname -- "$0")/install_coding_clis.sh"
install_macos_claude_code
print_coding_cli_login_reminder

printf 'macOS bootstrap complete.\n'
