#!/usr/bin/env sh

# Shared helpers for installing coding CLIs. This file is sourced by the
# platform bootstrap scripts and intentionally does not enable `set -e` itself.

coding_cli_path="$HOME/.local/bin:$PATH"

coding_cli_available() {
  coding_cli_name="$1"
  PATH="$coding_cli_path" command -v "$coding_cli_name" >/dev/null 2>&1
}

install_vendor_cli() {
  coding_cli_name="$1"
  coding_cli_url="$2"
  coding_cli_shell="${3:-sh}"

  if coding_cli_available "$coding_cli_name"; then
    return 0
  fi

  printf 'Installing %s...\n' "$coding_cli_name"
  curl -fsSL "$coding_cli_url" | "$coding_cli_shell"

  if ! coding_cli_available "$coding_cli_name"; then
    printf 'The %s installer completed, but %s is not on PATH.\n' \
      "$coding_cli_name" "$coding_cli_name" >&2
    return 1
  fi
}

install_npm_cli() {
  npm_cli_name="$1"
  npm_cli_package="$2"

  if coding_cli_available "$npm_cli_name"; then
    return 0
  fi

  if ! command -v npm >/dev/null 2>&1; then
    printf 'npm is required to install %s.\n' "$npm_cli_name" >&2
    return 1
  fi

  printf 'Installing %s...\n' "$npm_cli_name"
  npm install --prefix "$HOME/.local" -g --no-audit --no-fund "$npm_cli_package"

  if ! coding_cli_available "$npm_cli_name"; then
    printf 'The %s package installed, but %s is not on PATH.\n' \
      "$npm_cli_package" "$npm_cli_name" >&2
    return 1
  fi
}

install_linux_coding_clis() {
  # npm installs are noninteractive, which is important for headless
  # containers and Coder envbuilder builds. Authentication remains a separate
  # interactive step when the user first runs each CLI.
  install_npm_cli claude @anthropic-ai/claude-code
  install_npm_cli codex @openai/codex
  install_npm_cli opencode opencode-ai
}

install_macos_claude_code() {
  install_vendor_cli claude https://claude.ai/install.sh bash
}

install_copilot_cli_npm() {
  if coding_cli_available copilot; then
    return 0
  fi

  if ! command -v npm >/dev/null 2>&1; then
    printf 'npm is required to install GitHub Copilot CLI.\n' >&2
    return 1
  fi

  printf 'Installing GitHub Copilot CLI...\n'
  mkdir -p "$HOME/.local"
  npm install --prefix "$HOME/.local" -g @github/copilot

  if ! coding_cli_available copilot; then
    printf 'GitHub Copilot CLI was installed, but copilot is not on PATH.\n' >&2
    return 1
  fi
}

print_coding_cli_login_reminder() {
  printf '\nCoding CLIs installed. Authenticate each CLI when you first use it:\n'
  printf '  claude       # Claude Code login flow\n'
  printf '  codex        # choose Sign in with ChatGPT\n'
  printf '  opencode     # use /connect\n'
  printf '  copilot      # use /login\n'
}
