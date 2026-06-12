#!/usr/bin/env bash
# Keyboard-navigable action menu (fuzzel, dmenu mode).
# The top menu groups sections; each section opens its own submenu.
# Icons are Nerd Font glyphs emitted via printf \u escapes (raw glyphs don't
# survive in source); the case patterns use * to ignore the icon prefix.
# To add a section: add a line in main() and a matching function.

menu() { fuzzel --dmenu --hide-prompt --mesg "$1"; }

reload_configs() {
    case "$(printf ' Reload Hyprland\n Restart Waybar\n Back\n' | menu "Reload Configs")" in
        *"Reload Hyprland") hyprctl reload ;;
        *"Restart Waybar")  killall waybar; setsid -f waybar ;;
        *"Back")            main ;;
    esac
}

power() {
    case "$(printf ' Reboot\n Shut down\n Back\n' | menu "Power")" in
        *"Reboot")    systemctl reboot ;;
        *"Shut down") systemctl poweroff ;;
        *"Back")      main ;;
    esac
}

main() {
    case "$(printf ' Reload Configs\n Power\n' | menu "Actions")" in
        *"Reload Configs") reload_configs ;;
        *"Power")          power ;;
    esac
}

main
