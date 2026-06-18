# dotfiles-archlinux

A reproducible Arch Linux environment built around Hyprland. This repo contains
two independent scripts: one that installs Arch Linux itself, and one that
deploys the desktop environment on top of an existing install.

---

## Arch Linux installer (`archdotfiles.sh`)

An opinionated, mostly unattended Arch Linux installer. Boot from the official
Arch ISO, connect to the internet, set your timezone and keyboard layout, then
run:

```bash
curl -sL https://raw.githubusercontent.com/GiovanniOlan/dotfiles-archlinux/main/archdotfiles.sh -o archdotfiles.sh
bash archdotfiles.sh
```

The script asks only for the essentials — target disk, hostname, username,
password and LUKS passphrase — and handles everything else automatically.

### What it sets up

| Area | Detail |
| ---- | ------ |
| Partitioning | 1 GB EFI (FAT32) + rest of disk under LUKS |
| Encryption | LUKS2 with Argon2id |
| Filesystem | BTRFS with subvolumes: `@`, `@home`, `@snapshots`, `@var_log`, `@var_cache_pacman_pkg`, `@var_temp`, `@swap` |
| Swap | BTRFS swapfile with CoW disabled |
| Bootloader | GRUB with UEFI and full-disk encryption support |
| Single passphrase | A keyfile embedded in the initramfs unlocks LUKS after GRUB, so the passphrase is only entered once at boot |
| Init system | systemd-based mkinitcpio hooks (`sd-encrypt`) |
| Locale | `en_US.UTF-8` with `es_MX.UTF-8` for time, currency and regional formats |

### Prerequisites

- UEFI machine (legacy BIOS not supported)
- Boot from the [Arch Linux ISO](https://archlinux.org/download/)
- Internet connection
- Timezone set: `timedatectl set-timezone Region/City`
- Keyboard layout set: `loadkeys your_layout`

---

## Dotfiles installer (`dotfiles.sh`)

Clone the repo,
run `dotfiles.sh` from a base Arch install, and the environment is ready.

## What's included

| Area | What's included | Status |
| ---- | --------------- | ------ |
| Window management | Tiling, workspaces, window rules, keybindings (Hyprland) | done |
| Status bar | Clock, volume, microphone, connectivity, power profile, awake and do-not-disturb toggles (Waybar) | done |
| Audio | Full PipeWire stack with PulseAudio, JACK and ALSA compatibility | done |
| Connectivity | Bluetooth toggle and manager, network indicator | done |
| Power management | Performance profiles, suspend, reboot, shutdown | done |
| Application launching | Keyboard-driven launcher (Fuzzel) | done |
| File management | Graphical file manager (Nautilus) | done |
| Media & brightness | Play/pause, skip, volume and screen brightness via keyboard | done |
| Accessibility | Keyboard-driven pointer control (wl-kbptr) | done |
| System actions | Quick-access menu for common system operations | done |
| Screenshots | Region and full-screen capture, saved to file or clipboard | done |
| Clipboard | Wayland clipboard with persistent history picker (cliphist + fuzzel) | done |
| Notifications | Desktop notifications with a do-not-disturb toggle (mako) | done |
| Session start | TTY auto-login on tty1 launches Hyprland (requires LUKS full-disk encryption) | done |
| Wallpaper | Wallpaper setter that survives restarts | pending |
| Screen locking | Lock on demand, on idle and before sleep, with an awake (idle inhibitor) toggle (hyprlock + hypridle) | done |
| Authentication | Polkit agent for GUI privilege escalation dialogs | done |
| System fonts | Base fonts so apps render text correctly out of the box | done |

## Hardware-specific packages

These are not installed by `dotfiles.sh` because they depend on your hardware.
Install manually after running the script if they apply to your machine.

| Package | When to install |
| ------- | --------------- |
| `sof-firmware` | Intel laptops (~2020 onwards). Required for internal speakers and microphone to be detected. Without it, audio hardware exists but ALSA never registers it. |

## Per-machine font tuning

The font configuration in `fontconfig/fonts.conf` works out of the box on any display. If text rendering looks off on a specific machine, consider tuning hinting and antialiasing in that file — these settings are display-dependent and not worth hardcoding in a generic setup.

Relevant options: `antialias`, `hinting`, `hintstyle`, `rgba`, `lcdfilter`. See the [Arch Wiki on Font Configuration](https://wiki.archlinux.org/title/Font_configuration) for reference.
