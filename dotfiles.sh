#!/usr/bin/env bash
set -euo pipefail

##############################################
# Helpers
##############################################

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BOLD='\033[1m'
RESET='\033[0m'

info()  { echo -e "${BOLD}:: $*${RESET}"; }
ok()    { echo -e "${GREEN}[✓] $*${RESET}"; }
warn()  { echo -e "${YELLOW}[!] $*${RESET}"; }
die()   { echo -e "${RED}[✗] $*${RESET}" >&2; exit 1; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

##############################################
# Initial checks
##############################################

[[ $EUID -eq 0 ]] && die "Do not run as root."
ping -c1 -W3 archlinux.org &>/dev/null || die "No internet connection."

ok "Running as $USER."
ok "Internet connection verified."

# Prompt sudo once and keep it alive for the entire script
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT

mkdir -p ~/.config

##############################################
# User directories
##############################################

info "Setting up user directories..."

sudo pacman -S --needed --noconfirm xdg-user-dirs
cp "$DOTFILES_DIR/user-dirs/user-dirs.dirs" ~/.config/user-dirs.dirs
xdg-user-dirs-update
mkdir -p "$HOME/Pictures/Screenshots"

ok "User directories ready."

##############################################
# Base system
##############################################

info "Installing base system packages..."

sudo pacman -S --needed --noconfirm \
    git base-devel xdg-desktop-portal xdg-desktop-portal-hyprland pipewire wireplumber \
    pipewire-pulse pipewire-jack pipewire-alsa polkit polkit-gnome udisks2 \
    networkmanager

systemctl --user enable --now pipewire pipewire-pulse wireplumber
sudo systemctl enable --now NetworkManager

ok "Base system ready."

##############################################
# System fonts
##############################################

info "Installing fonts..."

sudo pacman -S --needed --noconfirm \
    noto-fonts noto-fonts-emoji noto-fonts-cjk \
    ttf-liberation ttf-carlito ttf-caladea \
    ttf-jetbrains-mono-nerd

ln -sfn "$DOTFILES_DIR/fontconfig" ~/.config/fontconfig

ok "Fonts ready."

##############################################
# Paru (AUR helper)
##############################################

if ! command -v paru &>/dev/null; then
    info "Installing paru..."
    tmp="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "$tmp/paru"
    (cd "$tmp/paru" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    ok "Paru installed."
else
    ok "Paru already installed, skipping."
fi

##############################################
# Hyprland
##############################################

info "Installing Hyprland..."

sudo pacman -S --needed --noconfirm \
    hyprland hyprlock hypridle \
    kitty nautilus brightnessctl playerctl fuzzel

paru -S --needed --noconfirm --sudoloop wl-kbptr

ln -sfn "$DOTFILES_DIR/hypr"     ~/.config/hypr
ln -sfn "$DOTFILES_DIR/wl-kbptr" ~/.config/wl-kbptr

ok "Hyprland ready."

##############################################
# Waybar
##############################################

info "Installing Waybar..."

sudo pacman -S --needed --noconfirm \
    waybar power-profiles-daemon python-gobject \
    pavucontrol calcurse blueman

sudo systemctl enable --now power-profiles-daemon
sudo systemctl enable --now bluetooth

ln -sfn "$DOTFILES_DIR/waybar" ~/.config/waybar

ok "Waybar ready."

##############################################
# Fuzzel
##############################################

ln -sfn "$DOTFILES_DIR/fuzzel" ~/.config/fuzzel

ok "Fuzzel config linked."

##############################################
# Clipboard
##############################################

info "Installing clipboard tools..."

sudo pacman -S --needed --noconfirm wl-clipboard cliphist

ok "Clipboard ready."

##############################################
# Notifications
##############################################

info "Installing notification daemon..."

sudo pacman -S --needed --noconfirm mako libnotify

ln -sfn "$DOTFILES_DIR/mako" ~/.config/mako

ok "Notifications ready."

##############################################
# Screenshots
##############################################

info "Installing screenshot tools..."

sudo pacman -S --needed --noconfirm grim slurp jq wl-clipboard libnotify
paru -S --needed --noconfirm --sudoloop grimblast-git

ok "Screenshots ready."

##############################################
# Action menu
##############################################

mkdir -p ~/.config/dotfiles-archlinux
ln -sfn "$DOTFILES_DIR/scripts" ~/.config/dotfiles-archlinux/scripts

ok "Action menu scripts linked."

##############################################
# Session start
# Requires LUKS full-disk encryption — the
# passphrase at boot serves as authentication.
##############################################

info "Configuring session start..."

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

ok "Session start configured."

echo
ok "Dotfiles deployed successfully."
