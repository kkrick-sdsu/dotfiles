#!/usr/bin/env sh
set -eu

if ! command -v pacman >/dev/null 2>&1; then
  echo "pacman not found. This script targets Arch-based systems."
  exit 1
fi

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
core_pkgs="tmux neovim curl"

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

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

printf 'Arch bootstrap complete.\n'
