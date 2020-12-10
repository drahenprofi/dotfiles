local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local clock_format = "%A %B %d, %H:%M"

local clock = wibox.widget.textclock()
clock.font = "Roboto Bold 10"
clock.format = "<span foreground='"..beautiful.fg_dark.."'>"..clock_format.."</span>"

return clock