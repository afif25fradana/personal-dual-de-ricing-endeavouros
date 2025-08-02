#!/usr/bin/env bash

# ==============================================================================
# KDE Plasma Ricing Automation Script (Definitive Version - Luna v5)
#
# Incorporates all iterative fixes and community feedback for a robust,
# bullet-proof installation on Arch-based systems.
# ==============================================================================

set -euo pipefail

# --- Logging Setup ---
readonly LOG_FILE="$HOME/kde-install-$(date +'%Y%m%d_%H%M%S').log"
exec &> >(tee -a "$LOG_FILE")

# --- Configuration & Packages ---
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
readonly KONSAVE_PROFILE_NAME="ricing_kde_full"
readonly KONSAVE_ARCHIVE_FILE="${SCRIPT_DIR}/KDE-Ricing/${KONSAVE_PROFILE_NAME}.knsv"

readonly PACMAN_PACKAGES=(
    base-devel git python-pipx python-pyqt5 kvantum papirus-icon-theme
    kconfig kwin plasma-workspace xorg-xrandr rsync
)
readonly AUR_PACKAGES=(
    plasma6-wallpapers-smart-video-wallpaper-reborn
)

# --- Helper Functions ---
log() { printf "\e[1;34m[INFO]\e[0m %s\n" "$1"; }
warn() { printf "\e[1;33m[WARN]\e[0m %s\n" "$1"; }
fail() {
    printf "\e[1;31m[FAIL]\e[0m %s\n" "$1" >&2
    printf "\e[1;31m[FAIL]\e[0m Full log: %s\n" "$LOG_FILE" >&2
    exit 1
}
run() {
    printf "\e[2m[RUN]\e[0m %s\n" "$*"
    if ! "$@"; then
        fail "Command failed: $*"
    fi
}

# --- Main Logic ---

pre_flight_checks() {
    log "Running pre-flight checks..."
    [[ -f /etc/arch-release ]] || fail "Arch-based distro required"
    [[ $EUID -ne 0 ]] || fail "Don't run as root"
    
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
    else
        AUR_HELPER=""
        warn "No AUR helper (yay/paru) found. AUR packages will be skipped."
        warn "You can install one with: sudo pacman -S yay"
    fi
}

install_packages() {
    log "Installing system and AUR packages..."
    run sudo pacman -Syu --needed --noconfirm "${PACMAN_PACKAGES[@]}"
    
    if [[ -n "$AUR_HELPER" ]]; then
        run "$AUR_HELPER" -S --needed --noconfirm "${AUR_PACKAGES[@]}"
    fi
}

setup_core_tools() {
    log "Setting up core tools..."
    run pipx install konsave
    run pipx inject konsave setuptools
    run pipx ensurepath
    export PATH="$HOME/.local/bin:$PATH"
}

verify_packages() {
    log "Verifying that critical commands are available..."
    for pkg_cmd in konsave kwriteconfig6 rsync; do
        if ! command -v "$pkg_cmd" &>/dev/null; then
            fail "Verification failed: '$pkg_cmd' command not found. Installation may be incomplete."
        fi
    done
    log "Critical commands verified."
}

install_assets() {
    log "Installing visual assets..."
    # Kvantum theme
    local theme_name="Sweet-transparent-toolbar"
    local theme_src="${SCRIPT_DIR}/KDE-Ricing/$theme_name"
    if [[ -d "$theme_src" ]]; then
        local theme_dest="$HOME/.config/Kvantum"
        mkdir -p "$theme_dest"
        run rsync -a --delete "$theme_src/" "$theme_dest/$theme_name/"
        run kwriteconfig6 --file "$theme_dest/kvantum.kvconfig" --group "General" --key "theme" "$theme_name"
        log "Kvantum theme configured."
    fi
    # Add other assets like cursors and wallpapers here if needed
}

apply_konsave_profile() {
    log "Applying konsave profile..."
    [[ -f "$KONSAVE_ARCHIVE_FILE" ]] || fail "Konsave profile missing: $KONSAVE_ARCHIVE_FILE"
    
    run konsave -i "$KONSAVE_ARCHIVE_FILE" --force
    run konsave -a "$KONSAVE_PROFILE_NAME"
    log "Konsave profile applied."
}

finalize() {
    log "Refreshing system configuration..."
    run kbuildsycoca6
    
    cat <<EOF

\e[1;32m==== INSTALLATION COMPLETE! ====\e[0m
1. Please \e[1;31mLOG OUT\e[0m and \e[1;31mLOG BACK IN\e[0m.
2. Verify all themes and settings are applied.

Full log available at: \e[1;34m$LOG_FILE\e[0m
EOF
}

# --- Main Execution ---
main() {
    echo -e "\n\e[1;35m==== KDE Ricing Installer (Definitive v5) ====\e[0m"
    
    pre_flight_checks
    install_packages
    setup_core_tools
    verify_packages
    install_assets
    apply_konsave_profile
    finalize
}

main
