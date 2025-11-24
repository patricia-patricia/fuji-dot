#!/usr/bin/env bash

set -e

# ========================= EDIT THIS =========================
REPO_URL="https://github.com/patricia-patricia/fuji-dot.git"
# =============================================================

FUJI_DIR="$HOME/fuji-dot"
BACKUP_ROOT="$FUJI_DIR/backup"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d_%H%M%S)"

echo "======================================================="
echo "      CachyOS / fuji-dot Installer"
echo "======================================================="
echo "Dotfiles : $FUJI_DIR"
echo "Backups  : $BACKUP_ROOT"
echo ""

# Create directories
mkdir -p "$FUJI_DIR"
mkdir -p "$BACKUP_ROOT"
mkdir -p "$BACKUP_DIR"

# Clone or update
if [ -d "$FUJI_DIR/.git" ]; then
    echo "Updating fuji-dot repository..."
    git -C "$FUJI_DIR" pull
else
    echo "Cloning repository into ~/fuji-dot ..."
    git clone "$REPO_URL" "$FUJI_DIR"
fi

# Yes/No helper
ask() {
    while true; do
        read -r -p "$1 [y/N] " choice
        case "$choice" in
            [Yy]*) return 0 ;;
            [Nn]*|"") return 1 ;;
            *) echo "Please answer y or n" ;;
        esac
    done
}

replace_config() {
    local name="$1"
    local src="$FUJI_DIR/$name"
    local dest="$HOME/.config/$name"

    if [ -e "$dest" ]; then
        echo "   Backing up ~/.config/$name → $BACKUP_DIR/"
        cp -r "$dest" "$BACKUP_DIR/" 2>/dev/null || true
    fi
    echo "   Deploying $name config..."
    cp -r "$src" "$HOME/.config/"
}

echo "Package & config selection:"
echo ""

if ask "Install waybar and deploy its config?"; then
    sudo pacman -S --needed --noconfirm waybar
    replace_config "waybar"
else
    echo "Skipping waybar"
fi

if ask "Install rofi and deploy its config?"; then
    sudo pacman -S --needed --noconfirm rofi
    replace_config "rofi"
else
    echo "Skipping rofi"
fi

echo ""

if ask "Replace default Hyprland keybindings and full hypr config? (hypr/)"; then
    replace_config "hypr"
else
    echo "Keeping your current Hyprland config (including keybinds.conf)"
fi

# Auto-clean old backups (keep only 3 newest)
echo ""
echo "Cleaning up old backups (keeping only the 3 newest)..."
cd "$BACKUP_ROOT" 2>/dev/null || true
ls -1dt .config_backup_* 2>/dev/null | tail -n +4 | xargs -I {} rm -rf "{}" || true

echo ""
echo "======================================================="
echo "Installation complete!"
echo "Dotfiles      : $FUJI_DIR"
echo "Latest backup : $BACKUP_DIR"
echo "Only 3 newest backups kept automatically"
echo "Log out or run 'hyprctl reload' to apply changes."
echo "======================================================="
