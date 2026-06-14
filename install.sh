#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

##############################################
# Base system
##############################################

sudo pacman -S --needed \
    pipewire wireplumber pipewire-pulse pipewire-jack pipewire-alsa

systemctl --user enable --now pipewire pipewire-pulse wireplumber

##############################################
# Hyprland
##############################################

sudo pacman -S --needed \
    kitty nautilus brightnessctl playerctl

# wl-kbptr is AUR-only
git clone https://aur.archlinux.org/wl-kbptr.git /tmp/wl-kbptr
(cd /tmp/wl-kbptr && makepkg -si)

ln -sfn "$DOTFILES_DIR/hypr" ~/.config/hypr

##############################################
# Waybar
##############################################

sudo pacman -S --needed \
    waybar ttf-jetbrains-mono-nerd power-profiles-daemon python-gobject \
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
# Action menu
##############################################

mkdir -p ~/.config/dotfiles-archlinux
ln -sfn "$DOTFILES_DIR/scripts" ~/.config/dotfiles-archlinux/scripts
