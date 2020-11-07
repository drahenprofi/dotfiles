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

local username = wibox.widget{
    markup = '<span foreground="'..beautiful.highlight..'">parndt</span>@<span foreground="'..beautiful.highlight..'">rouge</span>',
    font = "Fira Mono 14",
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

return wibox.widget {
    icon,
    username, 
    spacing = dpi(12),
    layout = wibox.layout.fixed.vertical
}