# Dotfiles

Personal dotfiles for Arch Linux with bash, tmux, and alacritty configurations.

## Features

- **Modern shell prompt** with starship (or fallback to custom prompt)
- **Enhanced productivity tools**: fzf, zoxide, eza, bat, fd, ripgrep
- **Smart fallbacks**: all configs work even if optional tools aren't installed
- **SSH key management** with keychain
- **Per-directory environments** with direnv
- **Git integration** with git-prompt and tig
- **Kubernetes support** with kubectl, kubectx, kubens, and kube-ps1
- **Tmux configuration** with plugin support via TPM
- **Alacritty terminal** with Iosevka Fixed font

## Quick Start

### 1. Clone this repository

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
```

### 2. Run the bootstrap script

```bash
./bootstrap.sh
```

This will:
- Install all recommended tools and dependencies
- Install three AUR helpers (paru, yay, aura) for redundancy
- Create symlinks for bash and starship configs
- Backup any existing files to `*.backup`

### 3. Reload your shell

```bash
source ~/.bashrc
```

## Installed Tools

### Core Shell Enhancements

- **starship** - Modern, fast, cross-shell prompt with context-aware information
- **fzf** - Fuzzy finder with extensive integrations
  - Git: branch checkout, log browser, file search, status, stash
  - Docker: exec, logs, stop/remove containers and images
  - Kubernetes: pod exec, logs, context/namespace switching
  - General: process killer, directory navigation, history search
  - See **Keybindings Cheatsheet** section below for all commands
- **zoxide** - Smarter `cd` command that learns your habits
  - Use `z <directory>` to jump to frequently used directories
- **keychain** - Manages SSH keys and agents
- **direnv** - Per-directory environment variables

### Modern CLI Tools

- **eza** - Modern replacement for `ls` with git integration
  - Aliases: `l`, `exals`, `ll`
- **bat** - `cat` with syntax highlighting and git integration
- **fd** - Modern `find` alternative
- **ripgrep (rg)** - Fast grep alternative
- **tig** - Text-mode interface for git

### File Management

- **nnn** - Fast terminal file manager

### Kubernetes Tools

- **kubectl** - Kubernetes CLI
- **kubectx** - Switch between Kubernetes clusters (alias: `kc`)
- **kubens** - Switch between Kubernetes namespaces (alias: `kn`)
- **kube-ps1** - Kubernetes prompt helper

### Optional Tools

- **atuin** - Shell history sync across machines
  - Run `atuin register` after installation to create an account

## Configuration

### Bash

- **bashrc** - Main bash configuration
  - Loads completions conditionally
  - Checks for missing tools and warns once per day
  - Integrates with starship or falls back to custom prompt
- **setenv** - Environment variables and PATH setup
  - Smart PAGER selection (bat → most → less)
  - Conditional tool loading (keychain, direnv)
- **bash_aliases** - Aliases and functions
  - Smart fallbacks (eza → exa → ls)
  - Docker, kubernetes, and git shortcuts

### Starship Prompt

The starship configuration (~/.config/starship.toml) matches your previous custom prompt:

**Line 1:** Exit code, time, user, host, language versions (Ruby, Rust), git status, kubernetes context, terraform workspace, docker context, AWS profile

**Line 2:** Current directory and prompt symbol

Customize it by editing `~/.config/starship.toml`.

### Tmux

The tmux configuration includes:
- **Modern terminal**: tmux-256color with true color support
- **Custom key bindings** (prefix: `Ctrl+B`) - see Keybindings section below
- **Mouse support** enabled
- **System monitoring**: CPU, battery status in status bar
- **Theme**: Tokyo Night (easily switchable to Nord)
- **Quick tool access**: htop, nmon, tig, man pages via prefix tables

After running bootstrap, start tmux and press `prefix + I` to install all plugins.

#### Switching Tmux Themes

Edit `~/.dotfiles/tmux/tmux.conf`:
1. Comment out current theme (add `#` before the lines)
2. Uncomment desired theme
3. Run: `tmux source ~/.config/tmux/tmux.conf`
4. Press: `prefix + I` to install the new theme plugin

Available themes:
- **Tokyo Night** (default) - Modern, colorful
- **Nord** - Arctic, bluish theme
- **Catppuccin** - Soothing pastel theme (4 variants)
- **Dracula** - Classic dark theme

### Alacritty

- Font: Iosevka Fixed (size 14)
- Color scheme: Custom dark theme
- Extensive keyboard bindings
- 10,000 lines of scrollback

## Fallback Behavior

All configurations gracefully handle missing tools:

- **Prompt**: Starship → Custom bash prompt
- **Pager**: bat → most → less
- **ls**: eza → exa → ls
- **Completions**: Loaded only if available
- **Tools**: fzf, zoxide, atuin, direnv - only initialized if installed

You'll see a one-time daily warning for missing recommended tools.

## Aliases

### File Operations

- `l` - Long listing with eza/exa
- `ll [file/dir]` - List directory or view file with bat
- `exals` - Detailed listing with all information

### Docker

- `dc` - docker-compose
- `dcra` - docker-compose run --rm app
- `dcr` - docker-compose run --rm backend bundle exec
- `dcr-sp` - docker-compose run with service ports

### Kubernetes

- `k` - kubectl
- `kc` - kubectx (switch clusters)
- `kn` - kubens (switch namespaces)
- `tf` - terraform

### Git

- `tig` - Interactive git client

### Other

- `mutt` - neomutt with gmail profile
- `mutt-work` - neomutt with work profile
- `svim` - vim with simple config
- `nnn` - File manager with cd-on-quit support

## Customization

### Adding More Tools

Edit `bootstrap.sh` and add packages to `OFFICIAL_PACKAGES` or `AUR_PACKAGES` arrays.

### Changing the Prompt

To customize starship, edit `~/.config/starship.toml`. See https://starship.rs/config/ for documentation.

To revert to the classic custom prompt, remove starship:

```bash
sudo pacman -R starship
```

### Modifying Aliases

Edit `~/.dotfiles/bash_aliases` and reload with `source ~/.bashrc`.

## Keybindings Cheatsheet

### Bash / Shell

| Keybinding | Action |
|------------|--------|
| `Ctrl+R` | FZF history search (enhanced) |
| `Ctrl+T` | FZF file finder |
| `Alt+C` | FZF directory navigator |
| `Ctrl+L` | Clear screen |
| `Ctrl+A` | Jump to beginning of line |
| `Ctrl+E` | Jump to end of line |
| `Ctrl+U` | Delete from cursor to beginning of line |
| `Ctrl+K` | Delete from cursor to end of line |
| `Ctrl+W` | Delete word before cursor |
| `Alt+Backspace` | Delete word before cursor |
| `Ctrl+D` | Exit shell / EOF |

### FZF Functions

#### Git Operations

| Command | Keybinding | Description |
|---------|------------|-------------|
| `gb` | - | Fuzzy checkout git branches (with preview) |
| `gl` | - | Interactive git log browser |
| `gf` | - | Fuzzy search git files |
| `gs` | - | Fuzzy git status - stage files interactively |
| `gst` | - | Browse git stash with preview |

**FZF Preview Controls (in FZF windows):**
- `Ctrl+/` - Toggle preview window
- `Ctrl+U` - Preview page up
- `Ctrl+D` - Preview page down
- `Ctrl+S` - Toggle sort (in git log)
- `Ctrl+M` / `Enter` - View full commit (in git log)

#### Docker Operations

| Command | Description |
|---------|-------------|
| `dex` | Exec into container (auto-detects bash/sh) |
| `dlog` | View logs for selected container |
| `dstop` | Stop containers interactively (multi-select) |
| `drm` | Remove containers interactively (multi-select) |
| `drmi` | Remove images interactively (multi-select) |

#### Kubernetes Operations

| Command | Description |
|---------|-------------|
| `kex [namespace]` | Exec into pod (default: default namespace) |
| `klog [namespace]` | View pod logs |
| `kdesc [namespace]` | Describe pod |
| `kctx` | Switch kubectl context with preview |
| `kns` | Switch kubectl namespace with preview |
| `kdel [namespace]` | Delete pods (multi-select) |
| `kres [namespace]` | Browse all resources in namespace |

**Note:** All k8s commands support optional namespace argument, default is `default`

#### General Utilities

| Command | Description |
|---------|-------------|
| `fkill [signal]` | Kill processes interactively (default: SIGKILL) |
| `up` | Navigate to parent directories |

### Tmux

**Prefix Key:** `Ctrl+B` (press prefix, then the command key)

#### Window Management

| Keybinding | Action |
|------------|--------|
| `Ctrl+T` | New window (in current directory) |
| `Shift+Left` | Previous window |
| `Shift+Right` | Next window |
| `Ctrl+Shift+Left` | Move window left |
| `Ctrl+Shift+Right` | Move window right |
| `prefix + Q` | Kill current window (with confirmation) |
| `prefix + S` | Kill server (with confirmation) |

#### Pane Management

| Keybinding | Action |
|------------|--------|
| `prefix + v` | Split pane horizontally |
| `prefix + s` | Split pane vertically |
| `prefix + hjkl` | Navigate panes (vim-style via pain-control plugin) |
| `prefix + HJKL` | Resize panes (vim-style via pain-control plugin) |
| `prefix + <` | Move pane left |
| `prefix + >` | Move pane right |
| `prefix + y` | Synchronize panes (type in all at once) |

#### Quick Tools (Prefix Tables)

Press `prefix + ~` for horizontal split or `prefix + `` ` (backtick) for vertical split, then:

| Key | Tool | Description |
|-----|------|-------------|
| `h` | htop | System monitor |
| `n` | nmon | Performance monitor |
| `t` | tig | Git interface (in current dir) |
| `l` | tail | Tail a file (prompts for path) |
| `/` | man | Open man page (prompts for command) |

#### Copy Mode

| Keybinding | Action |
|------------|--------|
| `prefix + Escape` | Enter copy mode |
| `prefix + [` | Enter copy mode (tmux-sensible) |
| *(in copy mode)* Emacs-style navigation |
| `prefix + ]` | Paste buffer |

#### Other

| Keybinding | Action |
|------------|--------|
| `prefix + m` | Toggle status bar |
| `prefix + I` | Install tmux plugins (TPM) |
| `prefix + U` | Update tmux plugins (TPM) |
| `prefix + t` | Show time |

### Alacritty Terminal

#### Font Size

| Keybinding | Action |
|------------|--------|
| `Ctrl+Plus` / `Ctrl+=` | Increase font size |
| `Ctrl+Minus` / `Ctrl+-` | Decrease font size |
| `Ctrl+0` | Reset font size |

#### Clipboard

| Keybinding | Action |
|------------|--------|
| `Ctrl+Shift+C` | Copy to clipboard |
| `Ctrl+Shift+V` | Paste from clipboard |
| `Shift+Insert` | Paste selection |
| `Middle Click` | Paste selection (mouse) |

#### Scrolling

| Keybinding | Action |
|------------|--------|
| `Shift+PageUp` | Scroll page up |
| `Shift+PageDown` | Scroll page down |

### Zoxide (Smart cd)

| Command | Description |
|---------|-------------|
| `z <partial>` | Jump to most frecent directory matching partial |
| `zi <partial>` | Interactive directory selection with fzf |
| `z -` | Go to previous directory |

### Common Tool Shortcuts

#### File Viewing

- `ll <file>` - View file with bat (syntax highlighting)
- `ll <dir>` - List directory with eza
- `l` - Detailed file listing with eza

#### Navigation

- `nnn` - File manager with cd-on-quit
- `z <dir>` - Smart directory jumping

## AUR Helpers

The bootstrap script installs three AUR helpers for redundancy:

- **paru** - Primary choice
- **yay** - Fallback if paru fails
- **aura** - Additional fallback

If one breaks after a system upgrade, you'll have backups.

## Troubleshooting

### Missing tools warning on every shell startup

Clear the warning cache:

```bash
rm ~/.cache/dotfiles_missing_tools_warned
```

### Starship not showing up

Check if it's installed and in PATH:

```bash
which starship
starship --version
```

### Completions not working

Reinstall bash-completion and bash-complete-alias:

```bash
sudo pacman -S bash-completion
paru -S bash-complete-alias
```

### Tmux plugins not loading

Install TPM first, then reload tmux config:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux source ~/.config/tmux/tmux.conf
# In tmux: prefix + I
```

## Credits

- Shell prompt powered by [starship](https://starship.rs/)
- Fuzzy finder by [fzf](https://github.com/junegunn/fzf)
- Smart navigation with [zoxide](https://github.com/ajeetdsouza/zoxide)
- History sync with [atuin](https://github.com/atuinsh/atuin)
