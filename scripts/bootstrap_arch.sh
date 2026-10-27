#!/usr/bin/env sh
set -eu

if ! command -v pacman >/dev/null 2>&1; then
  echo "pacman not found. This script targets Arch-based systems."
  exit 1
fi

required_node_major_version=22

node_major_version() {
  node --version 2>/dev/null | sed 's/^v//' | cut -d. -f1
}

if [ "$(id -u)" -eq 0 ]; then
  run_privileged() {
    "$@"
  }
else
  if ! command -v sudo >/dev/null 2>&1; then
    echo "This bootstrap must run as root or require sudo for a non-root user."
    exit 1
  fi

  run_privileged() {
    sudo "$@"
  }
fi

# Core tools
core_pkgs="tmux neovim curl nodejs npm"

# LSP servers matching Brewfile entries (when available in official repos)
lsp_pkgs="bash-language-server docker-language-server dockerfile-language-server lua-language-server marksman pyright typescript-language-server vscode-langservers-extracted yaml-language-server helm-ls"

install_pkgs=""
missing_pkgs=""

for pkg in $core_pkgs $lsp_pkgs; do
  if pacman -Si "$pkg" >/dev/null 2>&1; then
    install_pkgs="$install_pkgs $pkg"
  else
    missing_pkgs="$missing_pkgs $pkg"
  fi
  done

if [ -n "$install_pkgs" ]; then
  run_privileged pacman -Syu --needed $install_pkgs
fi

if [ -n "$missing_pkgs" ]; then
  echo "The following packages were not found in pacman and may require AUR:"
  echo "$missing_pkgs"
fi

if ! command -v node >/dev/null 2>&1 || [ "$(node_major_version)" -lt "$required_node_major_version" ] 2>/dev/null; then
  echo "Node.js $required_node_major_version or newer is required for GitHub Copilot CLI." >&2
  exit 1
fi

# Claude Code and Codex do not list Arch in their official system
# requirements. OpenCode is available in the official Arch repositories.
if ! command -v opencode >/dev/null 2>&1; then
  run_privileged pacman -S --needed opencode
fi

# shellcheck disable=SC1091
. "$(dirname -- "$0")/install_coding_clis.sh"
install_copilot_cli_npm
print_coding_cli_login_reminder

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

printf 'Arch bootstrap complete.\n'
