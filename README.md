# dotfiles-archlinux

A reproducible Arch Linux environment built around Hyprland. Clone the repo,
run `install.sh` from a base Arch install, and the environment is ready.

**Areas covered:**

| Area | What's included | Status |
| ---- | --------------- | ------ |
| Window management | Tiling, workspaces, window rules, keybindings (Hyprland) | done |
| Status bar | Clock, volume, microphone, connectivity, power profile (Waybar) | done |
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
| Session start | Display manager or TTY auto-login to launch Hyprland | pending |
| Wallpaper | Wallpaper setter that survives restarts | pending |
| Screen locking | Lock screen on suspend and on demand | pending |
| Authentication | Polkit agent for GUI privilege escalation dialogs | pending |
| System fonts | Base fonts so apps render text correctly out of the box | pending |

---

## Base system

```bash
pacman -S pipewire wireplumber pipewire-pulse pipewire-jack pipewire-alsa
```

| Package           | What it's for                                  |
| ----------------- | ---------------------------------------------- |
| `pipewire`        | Multimedia server (audio and video)            |
| `wireplumber`     | PipeWire session manager (provides `wpctl`)    |
| `pipewire-pulse`  | PulseAudio compatibility for apps              |
| `pipewire-jack`   | JACK compatibility (professional audio)        |
| `pipewire-alsa`   | Compatibility for apps using ALSA directly     |

Enable as user services so they start on login:

```bash
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

## Hyprland

### Install packages required.

```bash
pacman -S kitty nautilus brightnessctl playerctl fuzzel
```

```bash
git clone https://aur.archlinux.org/wl-kbptr.git
cd wl-kbptr
makepkg -si
```

| Program           | What it's for                               |
| ---------------   | ------------------------------------------- |
| `kitty`           | Terminal (`SUPER+RETURN`)                   |
| `nautilus`        | File manager (`SUPER+E`)                    |
| `fuzzel`          | Application launcher (`SUPER+P`)            |
| `brightnessctl`   | Brightness control                          |
| `playerctl`       | Media playback control                      |
| `wl-kbptr` (AUR)  | keyboard-driven pointer control (`SUPER+G`) |

### Install config.

```bash
ln -sfn ~/dotfiles-archlinux/hypr ~/.config/hypr
```

## Waybar

### Install packages required.

```bash
pacman -S waybar ttf-jetbrains-mono-nerd power-profiles-daemon python-gobject pavucontrol calcurse blueman
```

| Package                   | What it's for                                 |
| ------------------------- | --------------------------------------------- |
| `waybar`                  | Status bar                                    |
| `ttf-jetbrains-mono-nerd` | Nerd Font with the bar's icons                |
| `power-profiles-daemon`   | Power profile switching (`powerprofilesctl`)  |
| `python-gobject`          | Python bindings required by `powerprofilesctl`|
| `pavucontrol`             | GUI volume mixer (click on the volume module) |
| `calcurse`                | Interactive TUI calendar (click on the clock) |
| `blueman`                 | Bluetooth manager (click on the bluetooth icon)|

### Enable daemons.

```bash
systemctl enable --now power-profiles-daemon
systemctl enable --now bluetooth
```

### Install config.

```bash
ln -sfn ~/dotfiles-archlinux/waybar ~/.config/waybar
```

## Fuzzel

Theme for the launcher and the action menu.

### Install packages required.

```bash
pacman -S fuzzel
```

| Program         | What it's for                               |
| --------------- | ------------------------------------------- |
| `fuzzel`        | Application launcher (`SUPER+P`)            |

### Installa config.

```bash
ln -sfn ~/dotfiles-archlinux/fuzzel ~/.config/fuzzel
```

## Screenshots

Region, monitor, or full-screen capture. Each screenshot is saved to `~/Pictures/Screenshots`, copied to clipboard, and opened in the image viewer.

| Keybind | Action |
| ------- | ------ |
| `PRINT` | Region select |
| `SHIFT + PRINT` | Focused monitor |
| `CTRL + SHIFT + PRINT` | All monitors |

### Install packages required.

```bash
pacman -S grim slurp jq wl-clipboard imv
```

```bash
git clone https://github.com/hyprwm/contrib.git /tmp/hyprwm-contrib
(cd /tmp/hyprwm-contrib/grimblast && sudo make install)
```

| Package | What it's for |
| ------- | ------------- |
| `grim` | Screenshot capture |
| `slurp` | Region selection |
| `jq` | JSON parsing (grimblast dependency) |
| `wl-clipboard` | Copy to clipboard |
| `imv` | Image viewer (opens after capture) |
| `grimblast` (source) | Wrapper that orchestrates the above |

## Clipboard

Clipboard history stored automatically on every copy. Open the picker with `SUPER+V`.

### Install packages required.

```bash
pacman -S wl-clipboard cliphist fuzzel
```

| Package        | What it's for                                      |
| -------------- | -------------------------------------------------- |
| `wl-clipboard` | Wayland clipboard integration (`wl-copy`/`wl-paste`) |
| `cliphist`     | Stores clipboard history                           |
| `fuzzel`       | History picker (`SUPER+V`)                         |

## Action menu

Keyboard-navigable menu (via `fuzzel`) for quick system actions:
reload Hyprland, restart Waybar, power off... Opens with `SUPER + ESCAPE`.

Scripts live in `scripts/` and are linked to `~/.config/dotfiles-archlinux/`,
a dedicated space for repo utilities that don't belong to a specific program.

### Install packages required.

```bash
pacman -S fuzzel
```

### Install config.

```bash
mkdir -p ~/.config/dotfiles-archlinux
ln -sfn ~/dotfiles-archlinux/scripts ~/.config/dotfiles-archlinux/scripts
```
