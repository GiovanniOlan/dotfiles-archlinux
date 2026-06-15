hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "altgr-intl",
        
        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            -- natural_scroll = false,
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})
