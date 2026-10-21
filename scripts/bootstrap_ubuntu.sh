#!/usr/bin/env sh
set -eu

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found. This script targets Ubuntu/Debian."
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

run_privileged apt-get update

# Core tooling for this dotfiles repo and Neovim plugins.
run_privileged apt-get install -y \
  git \
  neovim \
  curl \
  unzip \
  build-essential \
  python3 \
  python3-pip \
  nodejs \
  npm \
  ripgrep \
  fd-find

# LSP servers available via npm.
run_privileged npm install -g \
  bash-language-server \
  dockerfile-language-server-nodejs \
  typescript-language-server \
  vscode-langservers-extracted \
  yaml-language-server \
  pyright \
  vim-language-server

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# LSP servers that may or may not exist in apt repositories.
apt_lsp_pkgs="lua-language-server helm-ls marksman"
installable=""
missing=""

for pkg in $apt_lsp_pkgs; do
  if apt-cache show "$pkg" >/dev/null 2>&1; then
    installable="$installable $pkg"
  else
    missing="$missing $pkg"
  fi
done

if [ -n "$installable" ]; then
  run_privileged apt-get install -y $installable
fi

if [ -n "$missing" ]; then
  echo "The following LSP servers were not found in apt and need manual install:"
  echo "$missing"
fi

printf 'Ubuntu bootstrap complete.\n'
