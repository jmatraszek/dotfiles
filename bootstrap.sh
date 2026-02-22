#!/bin/bash
# Bootstrap script for dotfiles dependencies
# Installs recommended tools for enhanced bash/tmux/alacritty experience

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}==>${NC} $1"; }
error() { echo -e "${RED}==>${NC} $1"; }

# Check if running on Arch Linux
if ! command -v pacman &>/dev/null; then
    error "This script is designed for Arch Linux (pacman required)"
    exit 1
fi

info "Starting dotfiles dependency installation..."

# Official repository packages
OFFICIAL_PACKAGES=(
    # Core shell enhancements
    atuin             # Sync shell history across machines
    starship          # Modern cross-shell prompt
    fzf               # Fuzzy finder for history/files
    zoxide            # Smarter cd command
    keychain          # SSH key management
    direnv            # Per-directory environment variables

    # Modern CLI tools
    eza               # Modern ls replacement
    bat               # cat with syntax highlighting
    fd                # Modern find alternative
    ripgrep           # Fast grep alternative
    dust              # Modern du (disk usage)
    duf               # Modern df (disk free)
    procs             # Modern ps (process viewer)
    btop              # Modern top/htop (system monitor)

    # Git & Docker tools
    git-delta         # Beautiful git diffs
    lazydocker        # Interactive docker TUI
    dive              # Docker image layer explorer

    # HTTP & network tools
    xh                # Modern curl/httpie alternative
    bandwhich         # Network bandwidth monitor (network top)
    dog               # Modern DNS client (better dig)
    gping             # Ping with graph
    trippy            # Modern traceroute with TUI

    # Kubernetes tools
    k9s               # Kubernetes TUI
    stern             # Multi-pod log tailing

    # Terminal & multiplexer
    tmux              # Terminal multiplexer (if not installed)

    # Completion & prompt helpers
    bash-completion   # General bash completions
    git               # Git (includes git-prompt.sh)
    tig               # Git client with completion

    # File management
    nnn               # Terminal file manager

    # Git & development tools
    lazygit           # Interactive git TUI
    jq                # JSON processor
    yq                # YAML processor
    tldr              # Simplified man pages

    # Kubernetes tools (optional, comment out if not needed)
    kubectl           # Kubernetes CLI
    kubectx           # Switch between clusters
    kubens            # Switch between namespaces
)

# AUR packages (optional but recommended)
AUR_PACKAGES=(
    bash-complete-alias    # Completion support for aliases
    kube-ps1               # Kubernetes prompt helper
    tmux-plugin-manager    # Tmux Plugin Manager (TPM)

    # System utilities
    viddy-bin              # Modern watch command
)

# AUR helpers to install (all three for redundancy)
AUR_HELPERS=(
    yay-bin
    paru-bin
    aura-bin
)

# Install official packages
info "Installing official repository packages..."
MISSING_OFFICIAL=()
for pkg in "${OFFICIAL_PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        MISSING_OFFICIAL+=("$pkg")
    fi
done

if [ ${#MISSING_OFFICIAL[@]} -gt 0 ]; then
    info "Installing: ${MISSING_OFFICIAL[*]}"
    sudo pacman -S --needed --noconfirm "${MISSING_OFFICIAL[@]}"
    success "Official packages installed"
else
    success "All official packages already installed"
fi

# Check for AUR helpers
info "Checking AUR helpers..."
INSTALLED_AUR_HELPERS=()
for helper in yay paru aura; do
    if command -v "$helper" &>/dev/null; then
        INSTALLED_AUR_HELPERS+=("$helper")
    fi
done

# Install AUR helpers if none exist
if [ ${#INSTALLED_AUR_HELPERS[@]} -eq 0 ]; then
    warn "No AUR helpers found. Installing yay-bin, paru-bin, and aura-bin for redundancy..."

    # Create temporary directory for building
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    for helper in "${AUR_HELPERS[@]}"; do
        info "Installing $helper..."
        git clone "https://aur.archlinux.org/${helper}.git"
        cd "$helper"
        makepkg -si --noconfirm
        cd ..
        success "$helper installed"
    done

    cd - > /dev/null
    rm -rf "$TEMP_DIR"

    # Update list of installed helpers
    for helper in yay paru aura; do
        if command -v "$helper" &>/dev/null; then
            INSTALLED_AUR_HELPERS+=("$helper")
        fi
    done
else
    info "Found existing AUR helper(s): ${INSTALLED_AUR_HELPERS[*]}"

    # Install any missing AUR helpers for redundancy
    MISSING_HELPERS=()
    for helper_bin in "${AUR_HELPERS[@]}"; do
        helper_name="${helper_bin%-bin}"
        if ! command -v "$helper_name" &>/dev/null; then
            MISSING_HELPERS+=("$helper_bin")
        fi
    done

    if [ ${#MISSING_HELPERS[@]} -gt 0 ]; then
        info "Installing missing AUR helper(s) for redundancy: ${MISSING_HELPERS[*]}"
        # Use first available helper to install the others
        AUR_CMD="${INSTALLED_AUR_HELPERS[0]}"
        $AUR_CMD -S --needed --noconfirm "${MISSING_HELPERS[@]}"
        success "Redundant AUR helpers installed"
    else
        success "All AUR helpers already installed (yay, paru, aura)"
    fi
fi

# Install AUR packages
if [ ${#AUR_PACKAGES[@]} -gt 0 ]; then
    info "Installing AUR packages..."

    # Use aura as primary AUR helper (most stable)
    if ! command -v aura &>/dev/null; then
        error "Aura not found! AUR helper installation may have failed."
        error "Please install aura manually and re-run bootstrap."
        exit 1
    fi

    info "Using aura for AUR packages..."
    MISSING_AUR=()
    FAILED_AUR=()

    for pkg in "${AUR_PACKAGES[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            MISSING_AUR+=("$pkg")
        fi
    done

    if [ ${#MISSING_AUR[@]} -gt 0 ]; then
        info "Installing: ${MISSING_AUR[*]}"

        # Try to install each package individually to collect failures
        for pkg in "${MISSING_AUR[@]}"; do
            info "Installing $pkg..."
            if ! sudo aura -A --needed --noconfirm "$pkg" 2>/dev/null; then
                warn "Failed to install: $pkg"
                FAILED_AUR+=("$pkg")
            fi
        done

        if [ ${#FAILED_AUR[@]} -eq 0 ]; then
            success "All AUR packages installed successfully"
        else
            warn "Some AUR packages failed to install (see errors below)"
        fi
    else
        success "All AUR packages already installed"
    fi
fi

# Post-installation setup
info "Running post-installation setup..."

# Create symlinks for dotfiles
info "Creating symlinks for dotfiles..."

DOTFILES_DIR="$HOME/.dotfiles"

# Backup and link configuration files
backup_and_link() {
    local src="$1"
    local dest="$2"

    # Extract just the filename from src for display
    local src_name=$(basename "$src")

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        warn "Backing up existing $dest to ${dest}.backup"
        mv "$dest" "${dest}.backup"
    fi

    if [ -L "$dest" ]; then
        # Remove existing symlink
        rm "$dest"
    fi

    ln -sf "$src" "$dest"
    success "Linked $src_name → $dest"
}

# Link bash files
backup_and_link "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
backup_and_link "$DOTFILES_DIR/bash_aliases" "$HOME/.bash_aliases"
backup_and_link "$DOTFILES_DIR/setenv" "$HOME/.setenv"

# Link starship config
mkdir -p "$HOME/.config"
backup_and_link "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"

# Link tmux config
mkdir -p "$HOME/.config/tmux"
backup_and_link "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

# Link ripgrep config
backup_and_link "$DOTFILES_DIR/ripgreprc" "$HOME/.ripgreprc"

# Link git config
backup_and_link "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"

# Link global gitignore
backup_and_link "$DOTFILES_DIR/gitignore" "$HOME/.gitignore"

echo ""
success "Installation complete!"
echo ""
info "Installed tools:"
echo "  Core shell enhancements:"
echo "    • starship      - Modern shell prompt"
echo "    • fzf           - Fuzzy finder (Ctrl+R for history, Ctrl+T for files)"
echo "    • zoxide        - Smart directory jumping (use 'z' command)"
echo "    • keychain      - SSH key management"
echo "    • direnv        - Per-directory environment variables"
echo ""
echo "  Modern CLI replacements:"
echo "    • eza           - Better ls (aliased as 'l' and 'exals')"
echo "    • bat           - Better cat with syntax highlighting"
echo "    • fd            - Better find"
echo "    • ripgrep       - Better grep"
echo "    • dust          - Better du (disk usage)"
echo "    • duf           - Better df (disk free)"
echo "    • procs         - Better ps (process viewer)"
echo "    • btop          - Better top/htop (system monitor)"
echo "    • xh            - Better curl (HTTP client)"
echo "    • viddy         - Better watch"
echo ""
echo "  Git tools:"
echo "    • tig           - Git text UI"
echo "    • lazygit       - Interactive git TUI"
echo "    • delta         - Beautiful git diffs"
echo "    • tldr          - Simplified man pages"
echo ""
echo "  Docker tools:"
echo "    • lazydocker    - Interactive docker TUI"
echo "    • dive          - Docker image layer explorer"
echo ""
echo "  Network tools:"
echo "    • bandwhich     - Network bandwidth monitor (run with sudo)"
echo "    • dog           - Modern DNS client (better dig)"
echo "    • gping         - Ping with graph"
echo "    • trippy        - Modern traceroute with TUI"
echo "    • xh            - Modern HTTP client (better curl)"
echo ""
echo "  Kubernetes tools:"
echo "    • kubectl       - Kubernetes CLI"
echo "    • k9s           - Kubernetes TUI (must-have!)"
echo "    • stern         - Multi-pod log tailing"
echo "    • kubectx       - Switch between clusters"
echo "    • kubens        - Switch between namespaces"
echo "    • kube-ps1      - Kubernetes prompt helper"
echo ""
echo "  Data tools:"
echo "    • jq            - JSON processor"
echo "    • yq            - YAML processor"
echo ""
echo "  File management:"
echo "    • nnn           - Terminal file manager"
echo ""
echo "  Completions & extras:"
echo "    • bash-completion       - General completions"
echo "    • bash-complete-alias   - Alias completions"
echo "    • atuin                 - Shell history sync (optional)"
echo "    • tmux-plugin-manager   - Tmux Plugin Manager (TPM)"
echo ""
info "AUR helpers available:"
for helper in yay paru aura; do
    if command -v "$helper" &>/dev/null; then
        echo "  • $helper"
    fi
done
echo ""
# Report failures if any
if [ ${#FAILED_AUR[@]} -gt 0 ]; then
    echo ""
    error "============================================"
    error "FAILED AUR PACKAGES (action required):"
    error "============================================"
    for pkg in "${FAILED_AUR[@]}"; do
        error "  • $pkg"
    done
    echo ""
    warn "Common causes:"
    echo "  - Binary packages (-bin) linked against old libraries"
    echo "  - Package maintainer hasn't updated yet"
    echo ""
    warn "Solutions:"
    echo "  - Try non-bin version: aura -A ${FAILED_AUR[0]%-bin}"
    echo "  - Wait for maintainer update"
    echo "  - Install manually from AUR"
    echo ""
fi

warn "Next steps:"
echo "  1. Reload your shell or run: source ~/.bashrc"
echo "  2. For tmux: start tmux and press 'prefix + I' to install plugins"
echo "  3. For atuin: run 'atuin register' to create an account (optional)"
echo "  4. If using Kubernetes, ensure kubeconfig is set up"
echo ""
