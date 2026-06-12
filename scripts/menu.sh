#!/usr/bin/env bash
# Keyboard-navigable action menu (fuzzel, dmenu mode).
# The top menu groups sections; each section opens its own submenu.
# Icons use ANSI-C quoting ($'\uXXXX') — look up codepoints at nerdfonts.com/cheat-sheet.
# To add a section: add a line in main() and a matching function.

menu() { fuzzel --dmenu --hide-prompt --mesg "$1"; }

reload_configs() {
    case "$(printf $'\uf021 Reload Hyprland\n\uf2f1 Restart Waybar\n\uf060 Back\n' | menu "Reload Configs")" in
        *"Reload Hyprland") hyprctl reload ;;
        *"Restart Waybar")  killall waybar; setsid -f waybar ;;
        *"Back")            main ;;
    esac
}

power_profile() {
    case "$(printf $'\uf06c Power Saver\n\uf0e7 Balanced\n\uf135 Performance\n\uf060 Back\n' | menu "Power Profile")" in
        *"Power Saver")  powerprofilesctl set power-saver  && notify-send "Power Profile" "Power Saver active" ;;
        *"Balanced")     powerprofilesctl set balanced      && notify-send "Power Profile" "Balanced active" ;;
        *"Performance")  powerprofilesctl set performance   && notify-send "Power Profile" "Performance active" ;;
        *"Back")         power ;;
    esac
}

power() {
    case "$(printf $'\uf021 Reboot\n\uf011 Shut down\n\uf135 Power Profile\n\uf060 Back\n' | menu "Power")" in
        *"Reboot")         systemctl reboot ;;
        *"Shut down")      systemctl poweroff ;;
        *"Power Profile")  power_profile ;;
        *"Back")           main ;;
    esac
}

main() {
    case "$(printf $'\uf021 Reload Configs\n\uf011 Power\n' | menu "Actions")" in
        *"Reload Configs") reload_configs ;;
        *"Power")          power ;;
    esac
}

main
