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

    # Terminal & multiplexer
    tmux              # Terminal multiplexer (if not installed)

    # Completion & prompt helpers
    bash-completion   # General bash completions
    git               # Git (includes git-prompt.sh)
    tig               # Git client with completion

    # File management
    nnn               # Terminal file manager

    # Kubernetes tools (optional, comment out if not needed)
    kubectl           # Kubernetes CLI
    kubectx           # Switch between clusters
    kubens            # Switch between namespaces
)

# AUR packages (optional but recommended)
AUR_PACKAGES=(
    atuin                  # Sync shell history across machines
    bash-complete-alias    # Completion support for aliases
    kube-ps1               # Kubernetes prompt helper
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

    # Find first working AUR helper
    AUR_CMD=""
    for helper in paru yay aura; do
        if command -v "$helper" &>/dev/null; then
            AUR_CMD="$helper"
            break
        fi
    done

    if [ -z "$AUR_CMD" ]; then
        error "No working AUR helper found!"
        exit 1
    fi

    info "Using $AUR_CMD for AUR packages..."
    MISSING_AUR=()
    for pkg in "${AUR_PACKAGES[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            MISSING_AUR+=("$pkg")
        fi
    done

    if [ ${#MISSING_AUR[@]} -gt 0 ]; then
        info "Installing: ${MISSING_AUR[*]}"
        $AUR_CMD -S --needed --noconfirm "${MISSING_AUR[@]}" || warn "Some AUR packages failed to install"
        success "AUR packages processed"
    else
        success "All AUR packages already installed"
    fi
fi

# Post-installation setup
info "Running post-installation setup..."

# Create symlinks for dotfiles
info "Creating symlinks for dotfiles..."

DOTFILES_DIR="$HOME/.dotfiles"

# Backup and link bash configuration files
backup_and_link() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        warn "Backing up existing $dest to ${dest}.backup"
        mv "$dest" "${dest}.backup"
    fi

    if [ -L "$dest" ]; then
        # Remove existing symlink
        rm "$dest"
    fi

    ln -sf "$src" "$dest"
    success "Linked $src → $dest"
}

# Link bash files
backup_and_link "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
backup_and_link "$DOTFILES_DIR/bash_aliases" "$HOME/.bash_aliases"
backup_and_link "$DOTFILES_DIR/setenv" "$HOME/.setenv"

# Link starship config
mkdir -p "$HOME/.config"
backup_and_link "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"

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
echo "  Modern CLI tools:"
echo "    • eza           - Better ls (aliased as 'l' and 'exals')"
echo "    • bat           - Syntax-highlighted cat"
echo "    • fd            - Modern find"
echo "    • ripgrep       - Fast grep"
echo ""
echo "  Git & file management:"
echo "    • tig           - Git client"
echo "    • nnn           - Terminal file manager"
echo ""
echo "  Kubernetes tools:"
echo "    • kubectl       - Kubernetes CLI"
echo "    • kubectx       - Switch between clusters"
echo "    • kubens        - Switch between namespaces"
echo "    • kube-ps1      - Kubernetes prompt helper"
echo ""
echo "  Completions & extras:"
echo "    • bash-completion       - General completions"
echo "    • bash-complete-alias   - Alias completions"
echo "    • atuin                 - Shell history sync (optional)"
echo ""
info "AUR helpers available:"
for helper in yay paru aura; do
    if command -v "$helper" &>/dev/null; then
        echo "  • $helper"
    fi
done
echo ""
warn "Next steps:"
echo "  1. Reload your shell or run: source ~/.bashrc"
echo "  2. For atuin: run 'atuin register' to create an account (optional)"
echo "  3. If using Kubernetes, ensure kubeconfig is set up"
echo ""
