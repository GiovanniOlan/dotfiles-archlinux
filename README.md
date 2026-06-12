# dotfiles-archlinux

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

### Keybinds

Programs required by the shortcuts defined in `hypr/keybinds.lua`:

```bash
pacman -S kitty nautilus fuzzel brightnessctl playerctl
```

| Program         | What it's for                           |
| --------------- | --------------------------------------- |
| `kitty`         | Terminal (`SUPER+RETURN`)               |
| `nautilus`      | File manager (`SUPER+E`)                |
| `fuzzel`        | Application launcher (`SUPER+P`)        |
| `brightnessctl` | Brightness control                      |
| `playerctl`     | Media playback control                  |

### Installation

```bash
ln -sfn ~/workspaces/dotfiles-archlinux/hypr ~/.config/hypr
```

## Waybar

```bash
pacman -S waybar ttf-jetbrains-mono-nerd power-profiles-daemon python-gobject pavucontrol
```

| Package                   | What it's for                                 |
| ------------------------- | --------------------------------------------- |
| `waybar`                  | Status bar                                    |
| `ttf-jetbrains-mono-nerd` | Nerd Font with the bar's icons                |
| `power-profiles-daemon`   | Power profile switching (`powerprofilesctl`)  |
| `python-gobject`          | Python bindings required by `powerprofilesctl`|
| `pavucontrol`             | GUI volume mixer (click on the volume module) |

Enable the daemon so it starts on boot:

```bash
systemctl enable --now power-profiles-daemon
```

### Installation

```bash
ln -sfn ~/workspaces/dotfiles-archlinux/waybar ~/.config/waybar
```

## Fuzzel

Theme for the launcher and the action menu, matching the Hyprland/Waybar palette.
No extra packages — `fuzzel` is already installed with Hyprland.

### Installation

```bash
ln -sfn ~/workspaces/dotfiles-archlinux/fuzzel ~/.config/fuzzel
```

## Action menu

Keyboard-navigable menu (via `fuzzel`) for quick system actions:
reload Hyprland, restart Waybar, power off... Opens with `SUPER + ESCAPE`.

Scripts live in `scripts/` and are linked to `~/.config/dotfiles-archlinux/`,
a dedicated space for repo utilities that don't belong to a specific program.

### Installation

```bash
mkdir -p ~/.config/dotfiles-archlinux
ln -sfn ~/workspaces/dotfiles-archlinux/scripts ~/.config/dotfiles-archlinux/scripts
```
