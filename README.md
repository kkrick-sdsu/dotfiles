# dotfiles

Personal dotfiles repo with a small install/uninstall system and OS bootstraps.

## Layout
- `config/` holds app configs (linked into `~/.config`).
- `home/` holds files that live directly in `$HOME` (e.g. `.zshrc`, `.gitconfig`).
- `scripts/` includes platform bootstrap scripts.

## Install
```sh
./install.sh
```

`install.sh` detects macOS, Debian/Ubuntu-family Linux, or Arch-family Linux and runs the matching bootstrap before linking the dotfiles. Unsupported systems skip package bootstrapping and continue with the dotfile install. A recognized bootstrap failure stops the install before links are created.

The Ubuntu and Arch bootstraps support root-based devcontainers directly. Non-root users need `sudo`; `uv` is installed for the invoking user.

## Uninstall (optional)
```sh
./uninstall.sh
```

## Bootstrap
```sh
./scripts/bootstrap_macos.sh
./scripts/bootstrap_ubuntu.sh
./scripts/bootstrap_arch.sh
```

## tmux
Config lives at `home/.tmux.conf` and is linked to `~/.tmux.conf`.

## iTerm2 (macOS only)
Place exported iTerm2 preferences in `config/iterm2/`. These are linked on macOS installs only.
