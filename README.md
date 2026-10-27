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

`install.sh` detects macOS, Debian/Ubuntu-family Linux, Arch-family Linux, or RHEL/Fedora-family Linux and runs the matching bootstrap before linking the dotfiles. Unsupported systems skip package bootstrapping and continue with the dotfile install. A recognized bootstrap failure stops the install before links are created.

The Ubuntu and Arch bootstraps support root-based devcontainers directly. Non-root users need `sudo`; `uv` is installed for the invoking user. The RHEL/Fedora bootstrap is intended for shared and HPC systems: it never uses `sudo` or a system package manager, and installs its downloaded runtimes and npm packages under `~/.local`.

The Neovim configuration requires Neovim 0.11 or newer. The Ubuntu bootstrap uses the distro package when it meets that requirement; otherwise it installs the pinned official Neovim release archive. Set `NVIM_VERSION` to override the fallback release version.

## Coding CLI support

The bootstraps install coding CLIs only where the vendor documents support for the platform and this repository has an automated installation path. Installation does not authenticate the tools or store credentials; complete each tool's login flow after installation.

| CLI | Debian/Ubuntu | macOS | Arch | RHEL/Fedora |
| --- | --- | --- | --- | --- |
| Claude Code | Supported | Supported | Not officially documented/supported | Supported |
| Codex CLI | Supported | Supported | Not officially documented/supported | Supported |
| OpenCode | Supported | Supported | Supported | Supported |
| GitHub Copilot CLI | Supported with Node.js 22+ | Supported | Supported with Node.js 22+ | Supported with Node.js 22+ |

On Arch, Claude Code and Codex can be attempted manually using their vendor installers, but this repository does not install them automatically because Arch is not listed in their official system requirements. The commands are:

```sh
curl -fsSL https://claude.ai/install.sh | bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
```

After installation, authenticate as prompted by each CLI. GitHub Copilot CLI uses `/login`, OpenCode uses `/connect`, and Codex supports signing in with ChatGPT.

To verify the installed runtime:

```sh
nvim --version
nvim --headless '+lua print(vim.version())' +qa
```

## Uninstall (optional)
```sh
./uninstall.sh
```

## Bootstrap
```sh
./scripts/bootstrap_macos.sh
./scripts/bootstrap_ubuntu.sh
./scripts/bootstrap_arch.sh
./scripts/bootstrap_rhel.sh
```

## tmux
Config lives at `home/.tmux.conf` and is linked to `~/.tmux.conf`.

## iTerm2 (macOS only)
Place exported iTerm2 preferences in `config/iterm2/`. These are linked on macOS installs only.
