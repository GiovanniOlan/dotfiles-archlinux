# dotfiles-archlinux

A reproducible Arch Linux environment built around Hyprland. Clone the repo,
run `install.sh` from a base Arch install, and the environment is ready.

## What's included

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
| Authentication | Polkit agent for GUI privilege escalation dialogs | done |
| System fonts | Base fonts so apps render text correctly out of the box | pending |

## Hardware-specific packages

These are not installed by `install.sh` because they depend on your hardware.
Install manually after running the script if they apply to your machine.

| Package | When to install |
| ------- | --------------- |
| `sof-firmware` | Intel laptops (~2020 onwards). Required for internal speakers and microphone to be detected. Without it, audio hardware exists but ALSA never registers it. |
