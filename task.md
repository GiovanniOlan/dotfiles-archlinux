# Pending Tasks

## Hyprland keybinds

- [x] **Mouse scroll workspaces** (`SUPER+scroll`): agregar `on_current_monitor = true` a los binds de `mouse_down` / `mouse_up` para que el scroll también traiga el workspace al monitor actual, consistente con `SUPER+N`.

- [x] **Mover ventana a workspace** (`SUPER+SHIFT+N`): `follow=false` + `focus on_current_monitor` vía dos `hyprctl dispatch` encadenados.

## Install script

- [ ] **Instalar paru**: agregar instalación de paru (AUR helper) en `install.sh` si no está ya instalado, antes de cualquier sección que requiera paquetes AUR.

## Entorno pendiente de implementar

- [ ] **Session start**: configurar auto-login desde TTY que lance Hyprland directamente, sin display manager.

- [ ] **Wallpaper**: integrar un setter de fondo de pantalla (ej. `swww` o `hyprpaper`) que persista entre reinicios y se inicie en el autostart de Hyprland.

- [ ] **Screen locking**: configurar bloqueo de pantalla automático al suspender y bajo demanda (ej. `hyprlock` + `hypridle`).

- [ ] **System fonts**: definir un set de fuentes base que garantice que las apps rendericen texto correctamente desde el primer arranque.
