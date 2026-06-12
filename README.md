# dotfiles-archlinux

## Sistema base

```bash
pacman -S pipewire wireplumber pipewire-pulse pipewire-jack pipewire-alsa
```

| Paquete           | Para qué sirve                                      |
| ----------------- | --------------------------------------------------- |
| `pipewire`        | Servidor multimedia (audio y video)                 |
| `wireplumber`     | Gestor de sesión de PipeWire (incluye `wpctl`)      |
| `pipewire-pulse`  | Compatibilidad con apps de PulseAudio               |
| `pipewire-jack`   | Compatibilidad con JACK (audio profesional)         |
| `pipewire-alsa`   | Compatibilidad con apps que usan ALSA directo       |

## Hyprland

### Keybinds

Programas que necesitan los atajos definidos en `hypr/keybinds.lua`:

```bash
pacman -S kitty nautilus fuzzel brightnessctl playerctl
```

| Programa        | Para qué sirve                          |
| --------------- | --------------------------------------- |
| `kitty`         | Terminal (`SUPER+RETURN`)               |
| `nautilus`      | Gestor de archivos (`SUPER+E`)          |
| `fuzzel`        | Launcher de aplicaciones (`SUPER+P`)    |
| `brightnessctl` | Control de brillo                       |
| `playerctl`     | Control de reproducción multimedia      |

### Instalación

```bash
ln -sfn ~/workspaces/dotfiles-archlinux/hypr ~/.config/hypr
```
