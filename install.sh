#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

##############################################
# User directories
##############################################

sudo pacman -S --needed xdg-user-dirs

ln -sfn "$DOTFILES_DIR/user-dirs/user-dirs.dirs" ~/.config/user-dirs.dirs
xdg-user-dirs-update

##############################################
# Base system
##############################################

sudo pacman -S --needed \
    git base-devel xdg-desktop-portal xdg-desktop-portal-hyprland pipewire wireplumber \
    pipewire-pulse pipewire-jack pipewire-alsa polkit polkit-gnome udisks2

systemctl --user enable --now pipewire pipewire-pulse wireplumber

##############################################
# System fonts
##############################################

sudo pacman -S --needed \
    noto-fonts noto-fonts-emoji noto-fonts-cjk \
    ttf-liberation ttf-carlito ttf-caladea \
    ttf-jetbrains-mono-nerd

ln -sfn "$DOTFILES_DIR/fontconfig" ~/.config/fontconfig

##############################################
# Paru (AUR helper)
##############################################

if ! command -v paru &>/dev/null; then
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && makepkg -si --noconfirm)
fi

##############################################
# Hyprland
##############################################

sudo pacman -S --needed \
    hyprland hyprlock hypridle \
    kitty nautilus brightnessctl playerctl fuzzel

paru -S --needed wl-kbptr

ln -sfn "$DOTFILES_DIR/hypr" ~/.config/hypr
ln -sfn "$DOTFILES_DIR/wl-kbptr" ~/.config/wl-kbptr

##############################################
# Waybar
##############################################

sudo pacman -S --needed \
    waybar power-profiles-daemon python-gobject \
    pavucontrol calcurse blueman

sudo systemctl enable --now power-profiles-daemon
sudo systemctl enable --now bluetooth

ln -sfn "$DOTFILES_DIR/waybar" ~/.config/waybar

##############################################
# Fuzzel
##############################################

sudo pacman -S --needed fuzzel 

ln -sfn "$DOTFILES_DIR/fuzzel" ~/.config/fuzzel

##############################################
# Screenshots
##############################################

sudo pacman -S --needed grim slurp jq wl-clipboard imv

paru -S --needed grimblast

mkdir -p ~/Pictures/Screenshots

##############################################
# Clipboard
##############################################

sudo pacman -S --needed wl-clipboard cliphist fuzzel

##############################################
# Action menu
##############################################

sudo pacman -S --needed fuzzel

mkdir -p ~/.config/dotfiles-archlinux
ln -sfn "$DOTFILES_DIR/scripts" ~/.config/dotfiles-archlinux/scripts

##############################################
# Session start
# Requires LUKS full-disk encryption — the
# passphrase at boot serves as authentication.
##############################################

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF
sudo systemctl daemon-reload

if ! grep -q 'exec start-hyprland' ~/.bash_profile 2>/dev/null; then
    cat >> ~/.bash_profile <<'EOF'

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
    exec start-hyprland
fi
EOF
fi