#!/usr/bin/env bash

# ==============================================================================
# KDE Plasma Ricing Automation Script
#
# What it does:
# - Clones the ricing repo.
# - Installs necessary packages and themes.
# - Applies the Konsave profile to set up the desktop.
#
# Made to be run on a fresh EndeavourOS (KDE) install.
# ==============================================================================

# Stop the script if any command fails. Safer this way.
set -euo pipefail

# --- Script Configuration ---
# All the important stuff is here for easy editing.
readonly REPO_URL="https://github.com/afif25fradana/personal-dual-de-ricing-endeavouros.git"
readonly REPO_DIR="$HOME/.local/share/personal-dual-de-ricing-endeavouros"
readonly KONSAVE_PROFILE_NAME="ricing_kde_full"
readonly KONSAVE_ARCHIVE_FILE="$REPO_DIR/KDE-Ricing/${KONSAVE_PROFILE_NAME}.knsv"

# --- Helper Functions ---
# Just for making the output look clean.
log() {
    printf "\e[1;32m[INFO]\e\e\e; then
        run git -C "$REPO_DIR" pull --ff-only
    else
        # Use --depth 1 for a faster clone, we don't need the full history.
        run git clone --depth 1 "$REPO_URL" "$REPO_DIR"
    fi
}

# 2. Install all the packages we need
install_dependencies() {
    log "Installing dependencies..."

    # THE MAIN FIX: Install python-pip and then Konsave itself.
    # This was the missing piece from the last script.
    log "Installing Python pip and Konsave..."
    run sudo pacman -S --needed --noconfirm python-pip
    run sudo pip install konsave

    # Install other packages from the official repos
    log "Installing packages from official repos..."
    run sudo pacman -S --needed --noconfirm papirus-icon-theme python-pyqt5 kvantum

    # Install the wallpaper plugin from the AUR
    log "Installing Smart Video Wallpaper plugin from AUR..."
    if! command -v yay &>/dev/null; then
        warn "'yay' is not installed. Skipping wallpaper plugin."
    else
        run yay -S --needed --noconfirm plasma6-wallpapers-smart-video-wallpaper-reborn
    fi
}

# 3. Install assets from our repo
install_manual_assets() {
    # Manually install the Sweet cursor theme
    log "Installing Sweet cursor theme manually..."
    local CURSOR_ARCHIVE="$REPO_DIR/KDE-Ricing/packages/Sweet-cursors.tar.xz"
    if; then
        local TEMP_DIR
        TEMP_DIR=$(mktemp -d) # Create a safe temporary directory
        run tar -xJf "$CURSOR_ARCHIVE" -C "$TEMP_DIR"
        run sudo cp -r "$TEMP_DIR"/Sweet-cursors /usr/share/icons/
        rm -rf "$TEMP_DIR" # Clean up after ourselves
        log "Cursor theme installed."
    else
        warn "Cursor theme archive not found. Skipping."
    fi

    # Copy the wallpaper video file
    log "Copying wallpaper..."
    local WALLPAPER_SOURCE="$REPO_DIR/KDE-Ricing/wallpaper/night-sky-purple-moon-clouds-moewalls-com.mp4"
    local WALLPAPER_DEST_DIR="$HOME/Videos/Wallpaper"
    mkdir -p "$WALLPAPER_DEST_DIR"
    run cp "$WALLPAPER_SOURCE" "$WALLPAPER_DEST_DIR/"
    log "Wallpaper copied to $WALLPAPER_DEST_DIR"
}

# 4. Apply theme configurations
apply_theme_configs() {
    # Set up the Kvantum theme
    log "Applying Kvantum theme..."
    local KVANTUM_SOURCE="$REPO_DIR/KDE-Ricing/Sweet-transparent-toolbar"
    local KVANTUM_DEST="$HOME/.config/Kvantum/"
    mkdir -p "$KVANTUM_DEST"
    run rsync -a "$KVANTUM_SOURCE" "$KVANTUM_DEST"
    
    # Set the Kvantum theme as the default
    if command -v kwriteconfig6 &>/dev/null; then
        run kwriteconfig6 --file "$HOME/.config/kvantum/kvantum.kvconfig" --group "General" --key "theme" "Sweet-transparent-toolbar"
    else
        warn "kwriteconfig6 not found. You might need to set the Kvantum theme manually."
    fi
}

# 5. Apply the Konsave profile
apply_konsave_profile() {
    log "Starting Konsave profile application..."
    if! command -v konsave &>/dev/null; then
        warn "'konsave' command not found. Skipping profile apply."
        return
    fi

    if; then
        warn "Konsave profile file not found at $KONSAVE_ARCHIVE_FILE. Skipping."
        return
    fi

    # Remove any old profile to ensure a clean import
    log "Removing any existing '${KONSAVE_PROFILE_NAME}' profile..."
    konsave -r "$KONSAVE_PROFILE_NAME" &>/dev/null |

| true # Ignore error if it doesn't exist

    log "Importing profile from $KONSAVE_ARCHIVE_FILE..."
    run konsave -i "$KONSAVE_ARCHIVE_FILE"

    log "Applying profile '${KONSAVE_PROFILE_NAME}'..."
    run konsave -a "$KONSAVE_PROFILE_NAME"

    log "Konsave profile applied successfully."
}

# --- Main execution function ---
main() {
    clone_or_update_repo
    install_dependencies
    install_manual_assets
    apply_theme_configs
    apply_konsave_profile

    log "Refreshing KDE system caches..."
    run kbuildsycoca6

    log "======================================================"
    log "Setup Complete!"
    log "Please LOG OUT and LOG IN again to see all changes."
    log "======================================================"
}

# Run the script
main
