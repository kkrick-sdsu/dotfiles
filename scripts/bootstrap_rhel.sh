#!/usr/bin/env sh
set -eu

# RHEL-family systems are common on shared/HPC systems where users cannot
# install packages system-wide. Keep every install under the user's home.
if [ "$(uname -s)" != "Linux" ]; then
  echo "This bootstrap targets Linux systems." >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required. Ask the system administrator to provide curl or load it from a module." >&2
  exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
  echo "tar is required. Ask the system administrator to provide tar or load it from a module." >&2
  exit 1
fi

required_node_major_version=22
required_neovim_version="0.11.0"
official_node_version="${NODE_VERSION:-22.14.0}"
official_neovim_version="${NVIM_VERSION:-0.11.7}"
local_prefix="${HOME}/.local"
local_bin="${local_prefix}/bin"
local_opt="${local_prefix}/opt"

mkdir -p "$local_bin" "$local_opt"
PATH="$local_bin:$PATH"
export PATH

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

  if [ "$actual_major" -gt "$required_major" ]; then return 0; fi
  if [ "$actual_major" -lt "$required_major" ]; then return 1; fi
  if [ "$actual_minor" -gt "$required_minor" ]; then return 0; fi
  if [ "$actual_minor" -lt "$required_minor" ]; then return 1; fi
  [ "$actual_patch" -ge "$required_patch" ]
}

node_major_version() {
  node --version 2>/dev/null | sed 's/^v//' | cut -d. -f1
}

neovim_version() {
  nvim --version 2>/dev/null | sed -n '1s/^NVIM v//p' | cut -d- -f1
}

archive_arch() {
  case "$(uname -m)" in
    x86_64) printf '%s\n' x86_64 ;;
    aarch64|arm64) printf '%s\n' arm64 ;;
    *)
      echo "No prebuilt RHEL-family archive is configured for $(uname -m)." >&2
      exit 1
      ;;
  esac
}

download_and_extract() {
  archive_url="$1"
  archive_file="$2"
  extract_dir="$3"

  temp_dir=$(mktemp -d)
  trap 'rm -rf "$temp_dir"' EXIT HUP INT TERM
  curl -fL --retry 3 -o "$temp_dir/$archive_file" "$archive_url"
  mkdir -p "$extract_dir"
  tar -C "$extract_dir" -xzf "$temp_dir/$archive_file"
  rm -rf "$temp_dir"
  trap - EXIT HUP INT TERM
}

install_node() {
  node_arch=$(archive_arch)
  node_dir="$local_opt/node-v${official_node_version}-linux-${node_arch}"
  node_archive="node-v${official_node_version}-linux-${node_arch}.tar.gz"
  node_url="https://nodejs.org/dist/v${official_node_version}/${node_archive}"

  if [ ! -x "$node_dir/bin/node" ]; then
    echo "Installing Node.js ${official_node_version} under ${local_opt}"
    download_and_extract "$node_url" "$node_archive" "$local_opt"
  fi

  ln -sfn "$node_dir/bin/node" "$local_bin/node"
  ln -sfn "$node_dir/bin/npm" "$local_bin/npm"
  ln -sfn "$node_dir/bin/npx" "$local_bin/npx"
}

install_neovim() {
  nvim_arch=$(archive_arch)
  nvim_dir="$local_opt/nvim-linux-${nvim_arch}"
  nvim_archive="nvim-linux-${nvim_arch}.tar.gz"
  nvim_url="https://github.com/neovim/neovim/releases/download/v${official_neovim_version}/${nvim_archive}"

  if [ ! -x "$nvim_dir/bin/nvim" ]; then
    echo "Installing Neovim ${official_neovim_version} under ${local_opt}"
    download_and_extract "$nvim_url" "$nvim_archive" "$local_opt"
  fi

  ln -sfn "$nvim_dir/bin/nvim" "$local_bin/nvim"
}

if ! command -v node >/dev/null 2>&1 || [ "$(node_major_version)" -lt "$required_node_major_version" ] 2>/dev/null; then
  install_node
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm was not found after installing Node.js." >&2
  exit 1
fi

if ! command -v nvim >/dev/null 2>&1 || ! version_at_least "$required_neovim_version" "$(neovim_version)"; then
  install_neovim
fi

if ! version_at_least "$required_neovim_version" "$(neovim_version)"; then
  echo "Neovim $(neovim_version) is below the required version $required_neovim_version." >&2
  exit 1
fi

# Install language servers without writing to a system prefix.
npm install --prefix "$local_prefix" -g \
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

printf 'RHEL-family user bootstrap complete. Ensure %s is on PATH.\n' "$local_bin"
