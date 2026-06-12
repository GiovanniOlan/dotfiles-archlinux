#!/usr/bin/env bash
# Menú de acciones del sistema, navegable con teclado vía fuzzel (modo dmenu).
# Cada línea de $options es una opción; el case de abajo ejecuta la elegida.

options="Recargar Hyprland
Reiniciar Waybar
Apagar"

choice=$(printf '%s\n' "$options" | fuzzel --dmenu --prompt "Acción: ")

case "$choice" in
    "Recargar Hyprland") hyprctl reload ;;
    "Reiniciar Waybar")  killall waybar; setsid -f waybar ;;
    "Apagar")            systemctl poweroff ;;
esac
