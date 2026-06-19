#!/usr/bin/env bash
set -euo pipefail

##############################################
# Helpers
##############################################
# Usage: bash archinstall.sh [--dev]
#   --dev   Dev/test mode: skips all prompts using hardcoded values.
#           NEVER use on a real machine.

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BOLD='\033[1m'
RESET='\033[0m'

info()  { echo -e "${BOLD}:: $*${RESET}"; }
ok()    { echo -e "${GREEN}[✓] $*${RESET}"; }
warn()  { echo -e "${YELLOW}[!] $*${RESET}"; }
die()   { echo -e "${RED}[✗] $*${RESET}" >&2; exit 1; }

DEV_MODE=false
[[ "${1:-}" == "--dev" ]] && DEV_MODE=true

if $DEV_MODE; then
    echo -e "${RED}${BOLD}"
    echo "  ██████╗ ███████╗██╗   ██╗    ███╗   ███╗ ██████╗ ██████╗ ███████╗"
    echo "  ██╔══██╗██╔════╝██║   ██║    ████╗ ████║██╔═══██╗██╔══██╗██╔════╝"
    echo "  ██║  ██║█████╗  ██║   ██║    ██╔████╔██║██║   ██║██║  ██║█████╗  "
    echo "  ██║  ██║██╔══╝  ╚██╗ ██╔╝    ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  "
    echo "  ██████╔╝███████╗ ╚████╔╝     ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗"
    echo "  ╚═════╝ ╚══════╝  ╚═══╝      ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝"
    echo -e "${RESET}"
    warn "DEV MODE — all prompts will be skipped with hardcoded test values."
    warn "NEVER run this flag on a real machine."
    echo
fi

##############################################
# Initial checks (silent)
##############################################

[[ $EUID -ne 0 ]] && die "Run as root."
[[ ! -d /run/archiso ]] && die "Not running from Arch ISO"
[[ ! -d /sys/firmware/efi ]] && die "UEFI not detected. Legacy BIOS is not supported."
ping -c1 -W3 archlinux.org &>/dev/null || die "No internet connection."

ok "UEFI detected."
ok "Internet connection verified."

##############################################
# Pre-flight warnings
##############################################

echo
warn "This script does NOT handle the following — do it before continuing:"
warn "  Set timezone:       timedatectl set-timezone Region/City"
warn "  Verify system clock: timedatectl status"
warn "  Set keyboard layout: loadkeys your_layout  (e.g. loadkeys es, loadkeys us)"
if ! $DEV_MODE; then
    echo
    read -rp "Everything is set. Continue? [y/N] " _c
    [[ "${_c,,}" != "y" ]] && exit 0
fi

##############################################
# Minimal prompts
##############################################

if $DEV_MODE; then
    INSTALL_DOTFILES=true
    echo
    info "Available disks:"
    lsblk -dpno NAME,SIZE,MODEL | grep -v "loop\|rom"
    echo
    read -rp "Target disk [default: /dev/sda]: " DISK
    DISK="${DISK:-/dev/sda}"
    [[ ! -b "$DISK" ]] && die "Not a valid block device: $DISK"
    HOSTNAME="archtest"
    USERNAME="testuser"
    USER_PASS="test"
    LUKS_PASS="testtest"
    SWAP_SIZE="1"
    warn "Dev values → disk=$DISK  host=$HOSTNAME  user=$USERNAME  swap=${SWAP_SIZE}G  dotfiles=$INSTALL_DOTFILES"
    echo
else
    echo
    read -rp "Install dotfiles on first boot? [y/N] " _d
    [[ "${_d,,}" == "y" ]] && INSTALL_DOTFILES=true || INSTALL_DOTFILES=false
    echo

    info "Available disks:"
    lsblk -dpno NAME,SIZE,MODEL | grep -v "loop\|rom"
    echo
    read -rp "Target disk (e.g. /dev/sda, /dev/nvme0n1): " DISK
    [[ ! -b "$DISK" ]] && die "Not a valid block device: $DISK"

    read -rp "Hostname: " HOSTNAME
    [[ -z "$HOSTNAME" ]] && die "Hostname cannot be empty."

    read -rp "Username: " USERNAME
    [[ -z "$USERNAME" ]] && die "Username cannot be empty."

    while true; do
        read -rsp "Password for $USERNAME: " USER_PASS; echo
        read -rsp "Confirm password: "        USER_PASS2; echo
        [[ "$USER_PASS" == "$USER_PASS2" ]] && break
        warn "Passwords do not match, try again."
    done
    unset USER_PASS2

    while true; do
        read -rsp "LUKS passphrase: "  LUKS_PASS; echo
        read -rsp "Confirm passphrase: " LUKS_PASS2; echo
        [[ "$LUKS_PASS" == "$LUKS_PASS2" ]] && break
        warn "Passphrases do not match, try again."
    done
    unset LUKS_PASS2

    read -rp "Swap size in GiB [default: 4]: " SWAP_SIZE
    SWAP_SIZE="${SWAP_SIZE:-4}"
fi

##############################################
# Final confirmation
##############################################

if ! $DEV_MODE; then
    echo
    warn "ALL data on $DISK will be destroyed."
    warn "Hostname: $HOSTNAME  |  User: $USERNAME  |  Swap: ${SWAP_SIZE}G"
    echo
    read -rp "Type YES to proceed: " _final
    [[ "$_final" != "YES" ]] && exit 0
fi

##############################################
# Auto-detection
##############################################

if grep -q "GenuineIntel" /proc/cpuinfo; then
    UCODE="intel-ucode"
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
    UCODE="amd-ucode"
else
    UCODE=""
fi

TIMEZONE=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "UTC")
KEYMAP=$(localectl status 2>/dev/null | awk '/VC Keymap/{print $3}')
[[ -z "$KEYMAP" || "$KEYMAP" == "(unset)" ]] && KEYMAP="us"

##############################################
# Clean up prior state (in case the script ran before and failed midway)
##############################################

swapoff /mnt/swap/swapfile 2>/dev/null || true
umount -R /mnt 2>/dev/null || true
cryptsetup close cryptroot 2>/dev/null || true

##############################################
# Partitioning
##############################################

info "Partitioning $DISK..."

sgdisk --zap-all "$DISK"
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI"  "$DISK"
sgdisk -n 2:0:0   -t 2:8300 -c 2:"LUKS" "$DISK"
partprobe "$DISK"
udevadm settle

if [[ "$DISK" =~ nvme|mmcblk ]]; then
    EFI_PART="${DISK}p1"
    LUKS_PART="${DISK}p2"
else
    EFI_PART="${DISK}1"
    LUKS_PART="${DISK}2"
fi

ok "Partitioned: $EFI_PART (EFI)  $LUKS_PART (LUKS)"

##############################################
# LUKS2
##############################################

info "Setting up LUKS2 (Argon2id)..."

echo -n "$LUKS_PASS" | cryptsetup luksFormat --type luks2 "$LUKS_PART" -
echo -n "$LUKS_PASS" | cryptsetup open "$LUKS_PART" cryptroot -

# Keyfile — unlocks LUKS from the initramfs so GRUB only asks once
dd bs=512 count=4 if=/dev/urandom of=/tmp/crypto_keyfile.bin 2>/dev/null
chmod 600 /tmp/crypto_keyfile.bin
echo -n "$LUKS_PASS" | cryptsetup luksAddKey "$LUKS_PART" /tmp/crypto_keyfile.bin -

unset LUKS_PASS

ok "LUKS container opened at /dev/mapper/cryptroot"

##############################################
# BTRFS + subvolumes
##############################################

info "Creating BTRFS filesystem..."
mkfs.btrfs -L archlinux /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt

info "Creating subvolumes..."
for sv in @ @home @snapshots @var_log @var_cache_pacman_pkg @var_temp @swap; do
    btrfs subvolume create "/mnt/$sv"
done

umount /mnt

##############################################
# Mount
##############################################

info "Mounting subvolumes..."

BTRFS_OPTS="noatime,compress=zstd,space_cache=v2"

mount -o "${BTRFS_OPTS},subvol=@" /dev/mapper/cryptroot /mnt

mkdir -p /mnt/{home,.snapshots,boot/efi,swap,var/log,var/cache/pacman/pkg,var/tmp}

mount -o "${BTRFS_OPTS},subvol=@home"                /dev/mapper/cryptroot /mnt/home
mount -o "${BTRFS_OPTS},subvol=@snapshots"           /dev/mapper/cryptroot /mnt/.snapshots
mount -o "${BTRFS_OPTS},subvol=@var_log"             /dev/mapper/cryptroot /mnt/var/log
mount -o "${BTRFS_OPTS},subvol=@var_cache_pacman_pkg" /dev/mapper/cryptroot /mnt/var/cache/pacman/pkg
mount -o "noatime,space_cache=v2,subvol=@var_temp"  /dev/mapper/cryptroot /mnt/var/tmp
mount -o "noatime,space_cache=v2,subvol=@swap"      /dev/mapper/cryptroot /mnt/swap

wipefs -a "$EFI_PART"
mkfs.fat -F32 -n EFI "$EFI_PART"
mount -t vfat "$EFI_PART" /mnt/boot/efi

ok "Filesystems mounted."

install -m600 /tmp/crypto_keyfile.bin /mnt/crypto_keyfile.bin
rm -f /tmp/crypto_keyfile.bin

##############################################
# Swapfile
##############################################

info "Creating swapfile (${SWAP_SIZE}G)..."

chattr +C /mnt/swap
truncate -s 0 /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=$(( SWAP_SIZE * 1024 )) status=progress
chmod 600 /mnt/swap/swapfile
mkswap /mnt/swap/swapfile
swapon /mnt/swap/swapfile

ok "Swapfile ready."

##############################################
# pacstrap
##############################################

info "Installing base system (this will take a while)..."

PKGS=(
    base linux linux-headers linux-firmware
    btrfs-progs
    grub efibootmgr
    networkmanager
    sudo git base-devel
    neovim
)
[[ -n "$UCODE" ]] && PKGS+=("$UCODE")

pacstrap -K /mnt "${PKGS[@]}"

##############################################
# fstab
##############################################

info "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

##############################################
# System configuration (chroot)
##############################################

info "Configuring system..."

LUKS_UUID=$(blkid -s UUID -o value "$LUKS_PART")

arch-chroot /mnt /bin/bash <<CHROOT
set -euo pipefail

# Timezone
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc

# Locale
sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sed -i 's/^#\(es_MX.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
cat > /etc/locale.conf <<'EOF'
LANG=en_US.UTF-8
LC_TIME=es_MX.UTF-8
LC_MONETARY=es_MX.UTF-8
LC_PAPER=es_MX.UTF-8
LC_MEASUREMENT=es_MX.UTF-8
LC_NUMERIC=es_MX.UTF-8
LC_ADDRESS=es_MX.UTF-8
LC_TELEPHONE=es_MX.UTF-8
LC_NAME=es_MX.UTF-8
EOF

# Keymap
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf

# Hostname
echo "${HOSTNAME}" > /etc/hostname
printf "127.0.0.1\tlocalhost\n::1\tlocalhost\n127.0.1.1\t${HOSTNAME}.localdomain ${HOSTNAME}\n" > /etc/hosts

# mkinitcpio — sd-encrypt requires systemd hooks; keyfile embedded in initramfs
sed -i 's/^HOOKS=.*/HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)/' /etc/mkinitcpio.conf
sed -i 's|^FILES=.*|FILES=(/crypto_keyfile.bin)|' /etc/mkinitcpio.conf
mkinitcpio -P
chmod 600 /boot/initramfs-*.img

# User
useradd -m -G wheel,audio,video,storage "${USERNAME}"
echo "${USERNAME}:${USER_PASS}" | chpasswd
passwd -l root

# sudo
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL$/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# GRUB
sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"rd.luks.name=${LUKS_UUID}=cryptroot rd.luks.key=/crypto_keyfile.bin root=/dev/mapper/cryptroot rootflags=subvol=@\"|" /etc/default/grub
sed -i 's/^#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Services
systemctl enable NetworkManager

CHROOT

unset USER_PASS

##############################################
# Dotfiles (first boot)
##############################################

if $INSTALL_DOTFILES; then
    info "Cloning dotfiles repo..."

    git clone https://github.com/GiovanniOlan/dotfiles-archlinux.git \
        "/mnt/home/${USERNAME}/dotfiles-archlinux"

    touch "/mnt/home/${USERNAME}/.dotfiles-pending"

    cat >> "/mnt/home/${USERNAME}/.bash_profile" <<'EOF'

if [[ -f ~/.dotfiles-pending ]]; then
    rm ~/.dotfiles-pending
    bash ~/dotfiles-archlinux/dotfiles.sh
fi
EOF

    arch-chroot /mnt chown -R "${USERNAME}:${USERNAME}" \
        "/home/${USERNAME}/dotfiles-archlinux" \
        "/home/${USERNAME}/.dotfiles-pending" \
        "/home/${USERNAME}/.bash_profile"

    ok "Dotfiles will install automatically on first login as ${USERNAME}."
fi

##############################################
# Cleanup and finish
##############################################

info "Unmounting..."
swapoff /mnt/swap/swapfile
umount -R /mnt
cryptsetup close cryptroot

echo
ok "Installation complete. Remove the installation media and reboot."
$INSTALL_DOTFILES && warn "On first login as ${USERNAME}, dotfiles will install automatically."
