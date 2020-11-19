local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")

local dpi = require("beautiful.xresources").apply_dpi

--[[local icon = wibox.widget{
    markup = '<span foreground="'..beautiful.green..'">ﲤ</span>',
    font = "Fira Mono 88",
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}]]--

local icon = wibox.widget {
    {
        {
            image = beautiful.avatar,
            widget = wibox.widget.imagebox
        },
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(200))
        end,
        widget = wibox.container.background
    },
    left = dpi(24), right = dpi(24),
    widget = wibox.container.margin
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
    spacing = dpi(16),
    layout = wibox.layout.fixed.vertical
}