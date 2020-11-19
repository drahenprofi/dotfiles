local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local dpi = require("beautiful.xresources").apply_dpi

local icon = wibox.widget {
    markup = "<span foreground='"..beautiful.blue.."'></span>",
    font = "Fira Mono 32",
    align = "center", 
    valign = "center",
    widget = wibox.widget.textbox
}

local uptime = wibox.widget {
    font = "Fira Mono 10",
    align = "center", 
    valign = "center",
    widget = wibox.widget.textbox
}

awful.widget.watch("uptime -p | sed 's/^...//'", 60, function(_, stdout)
    -- Remove trailing whitespaces
    local out = stdout:gsub('^%s*(.-)%s*$', '%1')--:gsub(", ", ",\n")
    uptime.text = out
end)

return wibox.widget {
    icon, 
    uptime, 
    spacing = dpi(12),
    layout = wibox.layout.fixed.horizontal
}