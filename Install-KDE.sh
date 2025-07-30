#!/usr/bin/env bash

# ==============================================================================
# KDE Plasma Ricing Automation Script (v6 - Home Logging Edition)
#
# Improvements:
# 1. Log files now saved directly in $HOME for easy access
# 2. More robust cursor theme installation
# 3. Automatic AUR helper fallback (yay → paru)
# 4. Better error handling for konsave
# ==============================================================================

set -euo pipefail

# --- Logging Setup (Now in HOME directory) ---
readonly LOG_FILE="$HOME/kde-install-$(date +'%Y%m%d_%H%M%S').log"
exec &> >(tee -a "$LOG_FILE")

# --- Script Configuration ---
readonly REPO_URL="https://github.com/afif25fradana/personal-dual-de-ricing-endeavouros.git"
readonly REPO_DIR="$HOME/.local/share/personal-dual-de-ricing-endeavouros"
readonly KONSAVE_PROFILE_NAME="ricing_kde_full"
readonly KONSAVE_ARCHIVE_FILE="$REPO_DIR/KDE-Ricing/${KONSAVE_PROFILE_NAME}.knsv"

# Try yay first, then paru
AUR_HELPER=""
if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
fi

# --- Helper Functions ---
log() {
    printf "\e[1;34m[INFO]\e[0m %s\n" "$1"
}

warn() {
    printf "\e[1;33m[WARN]\e[0m %s\n" "$1"
}

fail() {
    printf "\e[1;31m[FAIL]\e[0m %s\n" "$1" >&2
    printf "\e[1;31m[FAIL]\e[0m Full log saved to: %s\n" "$LOG_FILE" >&2
    exit 1
}

run() {
    printf "\e[2m[RUN]\e[0m %s\n" "$*"
    "$@"
}

# --- Main Functions ---

clone_or_update_repo() {
    log "Setting up ricing repository..."
    if [[ -d "$REPO_DIR" ]]; then
        log "Updating existing repository..."
        run git -C "$REPO_DIR" pull --ff-only
    else
        log "Cloning repository..."
        run git clone --depth 1 "$REPO_URL" "$REPO_DIR"
    fi
}

install_dependencies() {
    log "Installing core dependencies..."
    run sudo pacman -S --needed --noconfirm git base-devel python-pip python-setuptools
    
    # Python dependencies for konsave
    log "Installing konsave..."
    if ! command -v konsave &>/dev/null; then
        run pip install konsave --break-system-packages
        
        # Ensure konsave is in PATH
        if [[ ! ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
            log "Adding ~/.local/bin to PATH"
            export PATH="$HOME/.local/bin:$PATH"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        fi
    else
        log "Konsave already installed"
    fi

    log "Installing theme components..."
    run sudo pacman -S --needed --noconfirm \
        papirus-icon-theme \
        python-pyqt5 \
        kvantum \
        plasma-workspace \
        kconfig \
        kwin \
        xorg-xrandr

    # Install AUR package if helper is available
    if [[ -n "$AUR_HELPER" ]]; then
        log "Installing Smart Video Wallpaper from AUR using $AUR_HELPER..."
        run "$AUR_HELPER" -S --needed --noconfirm plasma6-wallpapers-smart-video-wallpaper-reborn
    else
        warn "No AUR helper found. Skipping Smart Video Wallpaper installation."
        warn "You can manually install it later with:"
        warn "  yay -S plasma6-wallpapers-smart-video-wallpaper-reborn"
    fi
}

install_cursor_theme() {
    log "Installing Sweet cursor theme..."
    local CURSOR_ARCHIVE="$REPO_DIR/KDE-Ricing/packages/Sweet-cursors.tar.xz"
    
    if [[ ! -f "$CURSOR_ARCHIVE" ]]; then
        warn "Cursor archive not found. Skipping installation."
        return
    fi

    local TEMP_DIR
    TEMP_DIR=$(mktemp -d)
    
    # Extract archive
    if ! run tar -xJf "$CURSOR_ARCHIVE" -C "$TEMP_DIR"; then
        warn "Failed to extract cursor theme"
        return
    fi
    
    # Find the cursor directory (more robust)
    local CURSOR_DIR
    CURSOR_DIR=$(find "$TEMP_DIR" -type d -name "*Sweet*" -print -quit)
    
    if [[ -z "$CURSOR_DIR" ]]; then
        warn "Could not find cursor directory in extracted files"
        return
    fi
    
    # Install to system
    run sudo cp -r "$CURSOR_DIR" /usr/share/icons/Sweet-cursors
    run sudo tee "/etc/environment.d/90-sweet-cursors.conf" >/dev/null <<EOF
XCURSOR_THEME=Sweet-cursors
XCURSOR_SIZE=24
EOF
    
    log "Sweet cursor theme installed system-wide"
}

install_wallpaper() {
    log "Installing wallpaper..."
    local WALLPAPER_SOURCE="$REPO_DIR/KDE-Ricing/wallpaper/night-sky-purple-moon-clouds-moewalls-com.mp4"
    local WALLPAPER_DEST_DIR="$HOME/Videos/Wallpaper"
    
    if [[ ! -f "$WALLPAPER_SOURCE" ]]; then
        warn "Wallpaper file not found. Skipping."
        return
    fi
    
    mkdir -p "$WALLPAPER_DEST_DIR"
    run cp "$WALLPAPER_SOURCE" "$WALLPAPER_DEST_DIR/"
    log "Wallpaper installed at: $WALLPAPER_DEST_DIR/$(basename "$WALLPAPER_SOURCE")"
}

install_kvantum_theme() {
    log "Installing Kvantum theme..."
    local KVANTUM_THEME_NAME="Sweet-transparent-toolbar"
    local KVANTUM_SOURCE="$REPO_DIR/KDE-Ricing/$KVANTUM_THEME_NAME"
    local KVANTUM_DEST="$HOME/.config/Kvantum"
    
    if [[ ! -d "$KVANTUM_SOURCE" ]]; then
        warn "Kvantum theme source not found. Skipping."
        return
    fi
    
    mkdir -p "$KVANTUM_DEST"
    run rsync -a "$KVANTUM_SOURCE/" "$KVANTUM_DEST/$KVANTUM_THEME_NAME/"
    
    # Set as default theme
    if command -v kvantummanager &>/dev/null; then
        run kvantummanager --set "$KVANTUM_THEME_NAME"
    else
        run kwriteconfig6 --file "$HOME/.config/Kvantum/kvantum.kvconfig" \
            --group "General" \
            --key "theme" \
            "$KVANTUM_THEME_NAME"
    fi
    
    log "Kvantum theme configured"
}

apply_konsave_profile() {
    log "Applying Konsave profile..."
    
    if ! command -v konsave &>/dev/null; then
        fail "konsave command not found - profile cannot be applied"
    fi
    
    if [[ ! -f "$KONSAVE_ARCHIVE_FILE" ]]; then
        fail "Konsave profile file missing: $KONSAVE_ARCHIVE_FILE"
    fi
    
    # Remove existing profile if present
    if konsave -l | grep -q "$KONSAVE_PROFILE_NAME"; then
        log "Removing existing profile: $KONSAVE_PROFILE_NAME"
        run konsave -r "$KONSAVE_PROFILE_NAME"
    fi
    
    # Import profile
    log "Importing profile..."
    if ! run konsave -i "$KONSAVE_ARCHIVE_FILE"; then
        fail "Failed to import Konsave profile"
    fi
    
    # Apply profile
    log "Applying profile: $KONSAVE_PROFILE_NAME"
    if ! run konsave -a "$KONSAVE_PROFILE_NAME"; then
        fail "Failed to apply Konsave profile. Check: ~/.cache/konsave/log.txt"
    fi
    
    log "Konsave profile applied successfully"
}

# --- Main Execution ---
main() {
    echo -e "\n\e[1;35m==== KDE Ricing Installer ====\e[0m"
    log "Log file: $LOG_FILE"
    
    clone_or_update_repo
    install_dependencies
    install_cursor_theme
    install_wallpaper
    install_kvantum_theme
    apply_konsave_profile
    
    log "Refreshing system configuration..."
    run kbuildsycoca6
    
    echo -e "\n\e[1;32m==== Installation Complete! ====\e[0m"
    log "Please LOG OUT and LOG BACK IN to apply all changes"
    log "If anything failed, check the log: $LOG_FILE"
    
    cat <<EOF

Next steps after login:
1. Open System Settings > Appearance
   - Icons: Select 'Papirus-Dark'
   - Cursors: Select 'Sweet-cursors'
2. Set wallpaper:
   - Choose 'Smart Video Wallpaper'
   - Set video path to: ~/Videos/Wallpaper/night-sky-purple-moon-clouds-moewalls-com.mp4
3. For transparency effects:
   - Open Kvantum Manager and ensure 'Sweet-transparent-toolbar' is selected

EOF
}

main
