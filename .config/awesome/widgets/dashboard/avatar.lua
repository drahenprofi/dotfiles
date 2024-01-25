local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")

local dpi = require("beautiful.xresources").apply_dpi

local weed = wibox.widget{
    markup = '<span foreground="'..beautiful.green..'">ﲤ</span>',
    font = "JetBrains Mono 48",
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local avatar = wibox.widget {
    {
        image = beautiful.avatar,
        widget = wibox.widget.imagebox
    },
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(8))
    end,
    widget = wibox.container.background
}

local username = wibox.widget{
    markup = '<span foreground="'..beautiful.highlight..'">parndt</span>@<span foreground="'..beautiful.highlight..'">rouge</span>',
    font = "JetBrains Mono 11",
    widget = wibox.widget.textbox
}

local uptime = wibox.widget {
    text = "up 0 minutes",
    font = "Roboto Regular 9",
    widget = wibox.widget.textbox
}

awful.widget.watch("uptime -p", 60, function(_, stdout)
    -- Remove trailing whitespaces
    local out = stdout:gsub('^%s*(.-)%s*$', '%1')--:gsub(", ", ",\n")
    uptime.text = out
end)

return wibox.widget {
    avatar, 
    {
        nil,
        {
            username, 
            uptime, 
            spacing = dpi(2),
            layout = wibox.layout.fixed.vertical
        },
        nil,
        expand = "none",
        layout = wibox.layout.align.vertical
    }, 
    spacing = dpi(16),
    layout = wibox.layout.fixed.horizontal
}