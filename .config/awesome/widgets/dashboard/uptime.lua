local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local uptime_text = wibox.widget.textbox()
uptime_text.font = "Fira Mono Bold 12"

awful.widget.watch("uptime -p | sed 's/^...//'", 60, function(_, stdout)
    -- Remove trailing whitespaces
    local out = stdout:gsub('^%s*(.-)%s*$', '%1')
    uptime_text.markup = "<span foreground='"..beautiful.fg_dark.."'>"..string.upper(out).."</span>"
end)

local uptimeWidget = wibox.widget {
    {
        image = beautiful.laptop_icon,
        forced_height = 32, 
        widget = wibox.widget.imagebox
    },
    uptime_text, 
    spacing = 24, 
    layout = wibox.layout.fixed.horizontal
}

return uptimeWidget