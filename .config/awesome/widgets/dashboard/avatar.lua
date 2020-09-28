local wibox = require("wibox")
local beautiful = require("beautiful")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local icon = wibox.widget{
    markup = '<span foreground="'..beautiful.green..'">ﲤ</span>',
    font = "Fira Mono 72",
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local arrow = wibox.widget{
    markup = '<span foreground="'..beautiful.highlight..'">></span>',
    font = "Fira Mono 16",
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local username = wibox.widget{
    markup = '<span foreground="'..beautiful.highlight_alt..'">parndt</span>',
    font = "Fira Mono 16",
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local image = wibox.widget {
    image = beautiful.avatar, 
    widget = wibox.widget.imagebox
}

return wibox.widget {
    icon,
    { 
        --icon,
        arrow,
        username, 
        spacing = dpi(12),
        layout = wibox.layout.fixed.horizontal
    },
    spacing = dpi(12),
    layout = wibox.layout.fixed.vertical
}