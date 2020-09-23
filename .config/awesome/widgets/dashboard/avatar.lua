local wibox = require("wibox")
local beautiful = require("beautiful")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local text = wibox.widget{
    markup = '<b><span foreground="'..beautiful.highlight..'">parndt</span></b>',
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
    image, 
    text,
    spacing = dpi(16),
    layout = wibox.layout.fixed.vertical
}