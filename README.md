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
- **fzf** - Fuzzy finder for files and command history
  - `Ctrl+R` - Search command history
  - `Ctrl+T` - Find files
  - `Alt+C` - Change directory
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
- **Custom key bindings** (prefix: `Ctrl+B`)
  - Split panes: `prefix + v` (horizontal), `prefix + s` (vertical)
  - Toggle status: `prefix + m`
  - New window in current path: `Ctrl+T`
  - Navigate windows: `Shift+Left/Right`
- **Mouse support** enabled
- **Session persistence**: Auto-saves every 15 minutes, restores on restart
- **System monitoring**: CPU, battery status in status bar
- **Theme**: Tokyo Night (easily switchable to Nord, Catppuccin, or Dracula)

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
