#!/usr/bin/env sh
set -eu

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

run_bootstrap() {
  bootstrap_script=""

  case "$(uname -s)" in
    Darwin)
      bootstrap_script="$REPO_DIR/scripts/bootstrap_macos.sh"
      ;;
    Linux)
      if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release

        case "${ID:-}" in
          ubuntu|debian|linuxmint|pop)
            bootstrap_script="$REPO_DIR/scripts/bootstrap_ubuntu.sh"
            ;;
          arch|manjaro|endeavouros)
            bootstrap_script="$REPO_DIR/scripts/bootstrap_arch.sh"
            ;;
          rhel|fedora|rocky|almalinux|centos|ol|amzn)
            bootstrap_script="$REPO_DIR/scripts/bootstrap_rhel.sh"
            ;;
        esac

        if [ -z "$bootstrap_script" ]; then
          case " ${ID_LIKE:-} " in
            *" debian "*)
              bootstrap_script="$REPO_DIR/scripts/bootstrap_ubuntu.sh"
              ;;
            *" arch "*)
              bootstrap_script="$REPO_DIR/scripts/bootstrap_arch.sh"
              ;;
            *" rhel "*|*" fedora "*)
              bootstrap_script="$REPO_DIR/scripts/bootstrap_rhel.sh"
              ;;
          esac
        fi
      fi
      ;;
  esac

  if [ -z "$bootstrap_script" ]; then
    printf 'No supported bootstrap found for this OS; continuing with dotfiles install.\n'
    return 0
  fi

  printf 'Running bootstrap: %s\n' "$bootstrap_script"
  "$bootstrap_script"
}

link_file() {
  src="$1"
  dest="$2"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$(readlink "$dest" 2>/dev/null || true)" = "$src" ]; then
      return 0
    fi
    mv "$dest" "${dest}.bak"
  fi

  ln -s "$src" "$dest"
}

link_children() {
  src_dir="$1"
  dest_dir="$2"

  for path in "$src_dir"/.[!.]* "$src_dir"/..?* "$src_dir"/*; do
    if [ ! -e "$path" ] && [ ! -L "$path" ]; then
      continue
    fi

    base=$(basename "$path")
    link_file "$path" "$dest_dir/$base"
  done
}

ensure_git_identity() {
  git_identity_file="$HOME/.gitconfig.local"
  if [ -f "$git_identity_file" ]; then
    return 0
  fi

  if [ ! -t 0 ]; then
    printf 'Skipping git identity prompt (no TTY). Create %s manually.\n' "$git_identity_file"
    return 0
  fi

  printf 'Git user name: '
  read -r git_name
  printf 'Git user email: '
  read -r git_email

  if [ -z "$git_name" ] || [ -z "$git_email" ]; then
    printf 'Skipping git identity setup (missing name or email). Create %s manually.\n' "$git_identity_file"
    return 0
  fi

  {
    printf '[user]\n'
    printf '  name = %s\n' "$git_name"
    printf '  email = %s\n' "$git_email"
  } >"$git_identity_file"
}

run_bootstrap

mkdir -p "$HOME/.config"

is_macos=false
if [ "$(uname -s)" = "Darwin" ]; then
  is_macos=true
fi

# Link config/ -> ~/.config
for dir in nvim git; do
  mkdir -p "$HOME/.config/$dir"
  link_children "$REPO_DIR/config/$dir" "$HOME/.config/$dir"
done

if $is_macos; then
  mkdir -p "$HOME/.config/iterm2"
  link_children "$REPO_DIR/config/iterm2" "$HOME/.config/iterm2"
fi

# Link home/ -> ~
link_children "$REPO_DIR/home" "$HOME"

ensure_git_identity

printf 'Installed dotfiles. Backups use the .bak suffix.\n'
