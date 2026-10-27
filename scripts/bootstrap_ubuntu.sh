#!/usr/bin/env sh
set -eu

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found. This script targets Ubuntu/Debian."
  exit 1
fi

# The GitHub Copilot CLI requires Node.js 22 or newer. Ubuntu/Debian package
# versions can lag behind, so use NodeSource only when the existing runtime is
# absent or too old.
required_node_major_version=22

node_major_version() {
  node --version 2>/dev/null | sed 's/^v//' | cut -d. -f1
}

ensure_node_min_version() {
  current_node_major=0
  if command -v node >/dev/null 2>&1; then
    current_node_major=$(node_major_version)
  fi

  if [ "$current_node_major" -ge "$required_node_major_version" ] 2>/dev/null; then
    return 0
  fi

  node_setup_script=$(mktemp)
  trap 'rm -f "$node_setup_script"' EXIT HUP INT TERM
  curl -fsSL "https://deb.nodesource.com/setup_${required_node_major_version}.x" -o "$node_setup_script"
  run_privileged bash "$node_setup_script"
  rm -f "$node_setup_script"
  trap - EXIT HUP INT TERM
  run_privileged apt-get install -y nodejs

  current_node_major=$(node_major_version)
  if [ "$current_node_major" -lt "$required_node_major_version" ] 2>/dev/null; then
    echo "Node.js $required_node_major_version or newer is required for GitHub Copilot CLI." >&2
    exit 1
  fi
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

required_neovim_version="0.11.0"
official_neovim_version="${NVIM_VERSION:-0.11.7}"
neovim_bin="nvim"

version_at_least() {
  version_at_least_required="$1"
  version_at_least_actual="$2"

  old_ifs="$IFS"
  IFS=.
  set -- $version_at_least_required
  required_major=${1:-0}
  required_minor=${2:-0}
  required_patch=${3:-0}

  set -- $version_at_least_actual
  actual_major=${1:-0}
  actual_minor=${2:-0}
  actual_patch=${3:-0}
  IFS="$old_ifs"

  if [ "$actual_major" -gt "$required_major" ]; then
    return 0
  fi
  if [ "$actual_major" -lt "$required_major" ]; then
    return 1
  fi
  if [ "$actual_minor" -gt "$required_minor" ]; then
    return 0
  fi
  if [ "$actual_minor" -lt "$required_minor" ]; then
    return 1
  fi
  [ "$actual_patch" -ge "$required_patch" ]
}

neovim_version() {
  "$neovim_bin" --version | sed -n '1s/^NVIM v//p' | cut -d- -f1
}

install_official_neovim() {
  official_arch=""
  case "$(uname -m)" in
    x86_64) official_arch="x86_64" ;;
    aarch64|arm64) official_arch="arm64" ;;
    *)
      echo "Neovim $(neovim_version) is too old, and no official release is configured for $(uname -m)."
      exit 1
      ;;
  esac

  archive_name="nvim-linux-$official_arch.tar.gz"
  archive_url="https://github.com/neovim/neovim/releases/download/v$official_neovim_version/$archive_name"
  install_dir="/opt/nvim-linux-$official_arch"
  temp_dir=$(mktemp -d)
  trap 'rm -rf "$temp_dir"' EXIT HUP INT TERM

  echo "Installing Neovim $official_neovim_version from $archive_url"
  curl -fL --retry 3 -o "$temp_dir/$archive_name" "$archive_url"
  run_privileged mkdir -p /opt
  run_privileged tar -C /opt -xzf "$temp_dir/$archive_name"

  if [ -e /usr/local/bin/nvim ] && [ ! -L /usr/local/bin/nvim ]; then
    run_privileged mv /usr/local/bin/nvim /usr/local/bin/nvim.bak
  fi
  run_privileged ln -sfn "$install_dir/bin/nvim" /usr/local/bin/nvim
  # Keep the remainder of this shell script from using the distro binary that
  # may already be cached by the shell after apt installed it.
  neovim_bin="$install_dir/bin/nvim"
  trap - EXIT HUP INT TERM
  rm -rf "$temp_dir"
}

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

if ! command -v nvim >/dev/null 2>&1 || ! version_at_least "$required_neovim_version" "$(neovim_version)"; then
  install_official_neovim
fi

if ! version_at_least "$required_neovim_version" "$(neovim_version)"; then
  echo "Neovim $(neovim_version) is below the required version $required_neovim_version."
  exit 1
fi

ensure_node_min_version

# LSP servers available via npm.
run_privileged npm install -g \
  bash-language-server \
  dockerfile-language-server-nodejs \
  typescript-language-server \
  vscode-langservers-extracted \
  yaml-language-server \
  pyright \
  vim-language-server

# shellcheck disable=SC1091
. "$(dirname -- "$0")/install_coding_clis.sh"
install_linux_coding_clis
install_copilot_cli_npm
print_coding_cli_login_reminder

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
