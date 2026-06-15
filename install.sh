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
    xdg-desktop-portal xdg-desktop-portal-hyprland pipewire wireplumber \
    pipewire-pulse pipewire-jack pipewire-alsa polkit polkit-gnome udisks2

systemctl --user enable --now pipewire pipewire-pulse wireplumber

##############################################
# Hyprland
##############################################

sudo pacman -S --needed \
    hyprland git base-devel \
    kitty nautilus brightnessctl playerctl fuzzel

# wl-kbptr is AUR-only
git clone https://aur.archlinux.org/wl-kbptr.git /tmp/wl-kbptr
(cd /tmp/wl-kbptr && makepkg -si)

ln -sfn "$DOTFILES_DIR/hypr" ~/.config/hypr
ln -sfn "$DOTFILES_DIR/wl-kbptr" ~/.config/wl-kbptr

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
# Screenshots
##############################################

sudo pacman -S --needed git base-devel scdoc \
    grim slurp jq wl-clipboard imv

git clone https://github.com/hyprwm/contrib.git /tmp/hyprwm-contrib
(cd /tmp/hyprwm-contrib/grimblast && sudo make install)

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