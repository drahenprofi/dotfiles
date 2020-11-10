local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local icon = wibox.widget{
    markup = '<span foreground="'..beautiful.green..'">ﲤ</span>',
    font = "Fira Mono 88",
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

-- uptime
local uptime = wibox.widget {
    font = "Fira Mono 10",
    align = "center", 
    valign = "center",
    wrap = "char",
    widget = wibox.widget.textbox
}

awful.widget.watch("uptime -p | sed 's/^...//'", 60, function(_, stdout)
    -- Remove trailing whitespaces
    local out = stdout:gsub('^%s*(.-)%s*$', '%1'):gsub(", ", ",\n")
    uptime.markup = "<span foreground='"..beautiful.fg_normal.."'>"..out.."</span>"
end)

return wibox.widget {
    icon,
    username, 
    uptime,
    spacing = dpi(12),
    layout = wibox.layout.fixed.vertical
}