# dotfiles-archlinux

A reproducible, opinionated Arch Linux setup built around **Hyprland**.

The repo ships **two independent layers** that you can use together or on their own:

1. **Arch Linux installer** — partitions, encrypts and installs a clean Arch system from the live ISO.
2. **Dotfiles installer** — deploys the full desktop environment (packages + symlinks) on top of any existing Arch install.

Both are deliberately opinionated: they encode one developer's preferred setup rather than trying to be a configurable framework. The installer can optionally chain the dotfiles at the end, but neither layer needs the other.

---

## Quick start

Pick the path that matches what you want to do.

### Install Arch Linux from scratch

Boot the [official Arch ISO](https://archlinux.org/download/), connect to the
internet, set your timezone and keyboard layout, then run:

```bash
curl -sL https://raw.githubusercontent.com/GiovanniOlan/dotfiles-archlinux/main/archinstall.sh -o archinstall.sh
bash archinstall.sh
```

It asks only for the essentials — target disk, hostname, username, password and
LUKS passphrase — and can deploy the dotfiles automatically on first boot if you
say yes.

### Deploy the dotfiles only

On an existing Arch install, logged in as the user you want to configure (not
root):

```bash
git clone https://github.com/GiovanniOlan/dotfiles-archlinux.git ~/dotfiles-archlinux
bash ~/dotfiles-archlinux/dotfiles.sh
```

It installs every package, links the configs into `~/.config`, and wires up the
session so Hyprland starts on login.

---

## The Arch installer

A mostly unattended installer. You answer a handful of unavoidable questions and
it builds the rest to a fixed, opinionated layout. Roughly, it:

- wipes the target disk and creates a **1 GB EFI partition** plus a single
  encrypted partition for everything else;
- sets up **LUKS2 encryption** (Argon2id) over that partition;
- formats it as **BTRFS** and lays out subvolumes so the system stays tidy and
  snapshot-friendly;
- installs the base system, configures locale, users and the bootloader, and
  optionally hands off to the dotfiles installer on first boot.

### Disk layout

| Area | Detail |
| ---- | ------ |
| Partitioning | 1 GB EFI (FAT32, unencrypted) + rest of disk under LUKS |
| Encryption | LUKS2 with Argon2id |
| Filesystem | BTRFS with `zstd` compression |
| Subvolumes | `@` (holds `/` and `/boot`), `@home`, `@snapshots`, `@var_log`, `@var_cache_pacman_pkg`, `@var_temp`, `@swap` |
| Swap | BTRFS swapfile on its own subvolume, copy-on-write disabled |
| Bootloader | GRUB (UEFI) with cryptodisk support |
| Single passphrase | A keyfile embedded in the initramfs unlocks LUKS after GRUB, so you type the passphrase only **once** at boot |
| Init | systemd-based `mkinitcpio` hooks (`sd-encrypt`) |
| Locale | `en_US.UTF-8`, with `es_MX.UTF-8` for time, currency and regional formats |

Keeping `/boot` inside the `@` subvolume means kernel and initramfs live
alongside the rest of the root subvolume, so a single snapshot captures a
bootable system state.

### Prerequisites

- A **UEFI** machine — legacy BIOS is not supported.
- Booted from the [Arch Linux ISO](https://archlinux.org/download/) with an
  internet connection.
- Timezone set: `timedatectl set-timezone Region/City`
- Keyboard layout set: `loadkeys your_layout` (e.g. `loadkeys es`)

> ⚠️ The installer **destroys all data** on the target disk. Double-check the
> device before confirming.

---

## The dotfiles

The desktop is a Wayland setup centered on Hyprland. Running `dotfiles.sh`
installs every package below and symlinks the matching config from this repo
into `~/.config`.

### Stack

| Role | Tool |
| ---- | ---- |
| Compositor | Hyprland (Wayland) |
| Lock & idle | Hyprlock + Hypridle |
| Shell | Bash |
| Terminal | Kitty |
| Status bar | Waybar |
| Notifications | Mako + libnotify |
| Launcher / pickers | Fuzzel |
| Clipboard | wl-clipboard + cliphist |
| Packages / AUR | Paru |

### What you get

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
| Screen locking | Lock on demand, on idle and before sleep, with an awake (idle inhibitor) toggle (hyprlock + hypridle) | done |
| Authentication | Polkit agent for GUI privilege escalation dialogs | done |
| System fonts | Base fonts so apps render text correctly out of the box | done |
| Wallpaper | Wallpaper setter that survives restarts | pending |

> The TTY auto-login assumes **LUKS full-disk encryption** — the boot passphrase
> is what authenticates you, so the desktop logs in automatically afterwards.

---

## Hardware-specific packages

These are **not** installed by `dotfiles.sh` because they depend on your
hardware. Install them manually if they apply.

| Package | When to install |
| ------- | --------------- |
| `sof-firmware` | Intel laptops (~2020 onwards). Required for internal speakers and microphone to be detected. Without it, the audio hardware exists but ALSA never registers it. |

## Per-machine font tuning

`fontconfig/fonts.conf` works out of the box on any display. If text rendering
looks off on a specific machine, tune hinting and antialiasing there — these
settings are display-dependent and not worth hardcoding in a generic setup.

Relevant options: `antialias`, `hinting`, `hintstyle`, `rgba`, `lcdfilter`. See
the [Arch Wiki on Font Configuration](https://wiki.archlinux.org/title/Font_configuration)
for reference.
