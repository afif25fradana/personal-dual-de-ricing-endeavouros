#!/usr/bin/env bash
# Install-KDE.sh - Robust KDE customization installer
# Repository: https://github.com/afif25fradana/personal-dual-de-ricing-endeavouros
set -Eeuo pipefail

# -------------------------- user-tunable variables -------------------------
REPO_URL="https://github.com/afif25fradana/personal-dual-de-ricing-endeavouros.git"
REPO_DIR="${HOME}/.local/share/personal-dual-de-ricing-endeavouros"

# Preferred AUR helper (yay or paru) - override with: AUR_HELPER=paru ./Install-KDE.sh
AUR_HELPER="${AUR_HELPER:-yay}"

KONSAVE_PROFILE_NAME="ricing_kde_full"
KONSAVE_FILE="${REPO_DIR}/KDE-Ricing/${KONSAVE_PROFILE_NAME}.knsv"
KVANTUM_THEME_NAME="Sweet-transparent-toolbar"
KVANTUM_SRC="${REPO_DIR}/KDE-Ricing/${KVANTUM_THEME_NAME}"

# Paths to local fallback files
SWEET_CURSOR_TAR="${REPO_DIR}/KDE-Ricing/packages/Sweet-cursors.tar.xz"
SMART_WALLPAPER_ZIP="${REPO_DIR}/KDE-Ricing/packages/plasma-smart-video-wallpaper-reborn-v2.3.2.zip"

# Wallpaper file name (hardcoded)
WALLPAPER_FILE="night-sky-purple-moon-clouds-moewalls-com.mp4"

# Suppress UserWarning from Konsave
export PYTHONWARNINGS="ignore::UserWarning"

# -------------------------- helpers ----------------------------------------
shopt -s extglob
dry_run=false
log_file="${HOME}/kde-install-$(date +%Y%m%d_%H%M%S).log"

log()   { echo -e "\e[1;32m[INSTALL]\e[0m $*" | tee -a "$log_file"; }
warn()  { echo -e "\e[1;33m[WARN]\e[0m    $*" | tee -a "$log_file"; }
err()   { echo -e "\e[1;31m[ERROR]\e[0m   $*" | tee -a "$log_file" >&2; }
die()   { err "$*"; exit 1; }

run() {
    if $dry_run; then
        printf "\e[36m[DRY]\e[0m %s\n" "$*" | tee -a "$log_file"
    else
        echo -e "\e[2m[RUN]\e[0m $*" | tee -a "$log_file"
        "$@" 2>&1 | tee -a "$log_file"
    fi
}

require_cmd() { command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"; }
backup_dir() {
    local src=$1
    [[ -d "$src" ]] || return 0
    local ts=$(date +%Y%m%d_%H%M%S)
    run mv "$src" "${src}_backup_${ts}"
}

cleanup_temp() {
    if [[ -n "${tmp_dir:-}" && -d "$tmp_dir" ]]; then
        rm -rf "$tmp_dir"
    fi
}
trap cleanup_temp EXIT

# -------------------------- argument parsing -------------------------------
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry) dry_run=true; shift ;;
        -h|--help)
            cat <<EOF
Usage: $0 [OPTIONS]

  --dry     Dry-run mode: show what would be done without touching the system
  -h,--help Show this help
EOF
            exit 0 ;;
        *) die "Unknown option: $1" ;;
    esac
done

# -------------------------- pre-flight checks ------------------------------
require_cmd git
require_cmd rsync
require_cmd kwriteconfig6
[[ -f /etc/arch-release ]] || die "This script is designed for Arch-based distros"
[[ $EUID -eq 0 ]] && die "This script must NOT be run as root. Please run as normal user."

# -------------------------- clone / update repo ----------------------------
log "Ensuring repo is present & up-to-date"
if [[ -d "$REPO_DIR/.git" ]]; then
    run git -C "$REPO_DIR" pull --ff-only
else
    run git clone --depth 1 "$REPO_URL" "$REPO_DIR"
fi

# -------------------------- verify assets exist ----------------------------
[[ -f "$KONSAVE_FILE" ]]      || die "Konsave file not found: $KONSAVE_FILE"
[[ -d "$KVANTUM_SRC" ]]       || die "Kvantum theme folder not found: $KVANTUM_SRC"

# Wallpaper: Hardcoded file name
WALLPAPER_SRC_DIR="${REPO_DIR}/KDE-Ricing/wallpaper"
WALLPAPER_TO_COPY="${WALLPAPER_SRC_DIR}/${WALLPAPER_FILE}"
[[ -f "$WALLPAPER_TO_COPY" ]] || die "Wallpaper file not found: $WALLPAPER_FILE"

# -------------------------- dependency check -------------------------------
log "Checking dependencies"
declare -a deps=(
    plasma-workspace papirus-icon-theme mpv python-pyqt5 python-pyqt6
    kconfig kvantum qt6-wayland xorg-xrandr
)

for pkg in "${deps[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        log "Installing $pkg"
        run sudo pacman -S --needed --noconfirm "$pkg"
    fi
done

# AUR helper install (only if missing)
if ! command -v "$AUR_HELPER" &>/dev/null; then
    [[ "$AUR_HELPER" == "yay" ]] || [[ "$AUR_HELPER" == "paru" ]] || \
        die "AUR_HELPER must be 'yay' or 'paru'"
    log "Installing $AUR_HELPER"
    run sudo pacman -S --needed --noconfirm base-devel git
    tmpdir=$(mktemp -d)
    run git clone "https://aur.archlinux.org/${AUR_HELPER}-bin.git" "$tmpdir/${AUR_HELPER}-bin"
    if ! run makepkg -si --noconfirm -C "$tmpdir/${AUR_HELPER}-bin"; then
        err "Failed to install $AUR_HELPER. Manual installation required."
        exit 1
    fi
    rm -rf "$tmpdir"
fi

# -------------------------- install cursor theme ---------------------------
install_sweet_cursor() {
    log "Installing Sweet Cursor theme"
    if [[ -f "$SWEET_CURSOR_TAR" ]]; then
        tmp_dir=$(mktemp -d)
        if run tar -xJf "$SWEET_CURSOR_TAR" -C "$tmp_dir"; then
            # Cari folder cursor yang benar
            cursor_dir=""
            if [[ -d "$tmp_dir/Sweet-cursors" ]]; then
                cursor_dir="$tmp_dir/Sweet-cursors"
            elif [[ -d "$tmp_dir/Sweet" ]]; then
                cursor_dir="$tmp_dir/Sweet"
            elif [[ -d "$tmp_dir/cursors" ]]; then
                cursor_dir="$tmp_dir"
            fi

            if [[ -n "$cursor_dir" ]]; then
                run sudo cp -r "$cursor_dir" /usr/share/icons/Sweet-cursors
                # Set environment variable
                run sudo mkdir -p "/etc/environment.d"
                echo "XCURSOR_THEME=Sweet-cursors" | sudo tee "/etc/environment.d/90-sweet-cursors.conf" >/dev/null
                echo "XCURSOR_SIZE=24" | sudo tee -a "/etc/environment.d/90-sweet-cursors.conf" >/dev/null
                log "Cursor theme installed globally"
            else
                warn "Could not find cursor directory in extracted files"
            fi
        else
            err "Failed to extract Sweet Cursor theme"
        fi
        rm -rf "$tmp_dir"
    else
        warn "Sweet-cursors.tar.xz not found, skipping cursor installation"
    fi
}

install_sweet_cursor

# -------------------------- install smart wallpaper plugin -----------------
install_smart_wallpaper() {
    log "Installing Smart Video Wallpaper plugin"
    if ! pacman -Qi plasma6-wallpapers-smart-video-wallpaper-reborn &>/dev/null; then
        log "Installing from AUR"
        if ! run "$AUR_HELPER" -S --needed --noconfirm plasma6-wallpapers-smart-video-wallpaper-reborn; then
            warn "Failed to install from AUR. Trying local fallback..."
            if [[ -f "$SMART_WALLPAPER_ZIP" ]]; then
                log "Installing from local file"
                tmp_dir=$(mktemp -d)
                if run unzip -q "$SMART_WALLPAPER_ZIP" -d "$tmp_dir"; then
                    run sudo cp -r "$tmp_dir"/* /usr/share/plasma/wallpapers/
                    log "Smart Wallpaper plugin installed from local file"
                else
                    err "Failed to extract Smart Wallpaper"
                fi
                rm -rf "$tmp_dir"
            else
                warn "No local fallback available for Smart Wallpaper"
            fi
        fi
    fi
}

install_smart_wallpaper

# -------------------------- deploy assets ---------------------------------
log "Deploying wallpaper"
WALL_DST="${HOME}/Videos/Wallpaper"
mkdir -p "$WALL_DST"
WALLPAPER_DST_FILE="${WALL_DST}/$(basename "$WALLPAPER_TO_COPY")"
if [[ -f "$WALLPAPER_DST_FILE" ]]; then
    backup_dir "${WALLPAPER_DST_FILE}"
fi
run cp "$WALLPAPER_TO_COPY" "$WALL_DST/"

log "Wallpaper installed at: $WALLPAPER_DST_FILE"

log "Deploying Kvantum theme"
KVANTUM_DST="${HOME}/.config/Kvantum"
backup_dir "${KVANTUM_DST}/${KVANTUM_THEME_NAME}"
run rsync -a "$KVANTUM_SRC" "$KVANTUM_DST/"
run kwriteconfig6 --file kvantumrc --group General --key theme "$KVANTUM_THEME_NAME"

# -------------------------- import konsave ---------------------------------
if command -v konsave &>/dev/null; then
    log "Importing konsave profile"

    # Delete if profile already exists
    if konsave -l | grep -qw "$KONSAVE_PROFILE_NAME"; then
        log "Removing existing profile: $KONSAVE_PROFILE_NAME"
        run konsave -r "$KONSAVE_PROFILE_NAME"
    fi

    log "Importing profile from: $KONSAVE_FILE"
    run konsave -i "$KONSAVE_FILE"

    # Verify import
    if ! konsave -l | grep -qw "$KONSAVE_PROFILE_NAME"; then
        die "Failed to import konsave profile: $KONSAVE_PROFILE_NAME"
    fi

    # Apply by NAME
    log "Applying konsave profile: $KONSAVE_PROFILE_NAME"
    if run konsave -a "$KONSAVE_PROFILE_NAME"; then
        log "Konsave profile applied successfully"
    else
        err "Failed to apply profile. Try manual command:"
        err "  konsave -a '$KONSAVE_PROFILE_NAME'"
        err "Or check konsave logs: ~/.cache/konsave_log.txt"
    fi
else
    warn "Konsave is not installed; skipping profile import."
fi

# -------------------------- final steps -----------------------------------
log "Refreshing caches"
run kbuildsycoca6

log "Installation complete!"
log "Please MANUALLY log out and log back in to apply all changes"

cat << "EOF"

      |\      _,,,---,,_
ZZZzz /,`.-'`'    -.  ;-;;,_
     |,4-  ) )-,_. ,\ (  `'-'
    '---''(_/--'  `-'\_)

   KDE Ricing Successfully Installed!

   Next steps:
   1. Log out and log back in
   2. Open System Settings > Appearance > Cursor
      - Select 'Sweet-cursors'
   3. Open System Settings > Wallpaper
      - Choose 'Smart Video Wallpaper'
      - Set video path to: ~/Videos/Wallpaper/night-sky-purple-moon-clouds-moewalls-com.mp4
EOF

# Print log file location
echo -e "\nLog file created at: $log_file"

exit 0
