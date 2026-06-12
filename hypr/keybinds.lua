local p       = require("programs")
local mainMod = "SUPER"

-- ── Apps ─────────────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(p.terminal))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(p.fileManager))
hl.bind(mainMod .. " + P",      hl.dsp.exec_cmd(p.menu))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("$HOME/.config/dotfiles-archlinux/scripts/menu.sh"))

-- ── Window ────────────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(
    "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"
))

-- ── Focus (vim keys) ──────────────────────────────────────────────────────────
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down"  }))

-- ── Workspaces ────────────────────────────────────────────────────────────────
for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

local extra = { z = 6, x = 7, c = 8, d = 9 }
for key, ws in pairs(extra) do
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = ws }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- ── Media ────────────────────────────────────────────────────────────────
-- Volume (wpctl / PipeWire)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })

-- Brightness (brightnessctl)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Playback (playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
