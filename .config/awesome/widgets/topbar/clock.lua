local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local clock_format = "%A %B %d, %H:%M"

local clock = wibox.widget.textclock()
clock.font = "Roboto Bold 10"
clock.format = "<span foreground='"..beautiful.bg_normal.."'>"..clock_format.."</span>"

return wibox.widget {
    {
        clock,
        left = dpi(4), right = dpi(4),
        widget = wibox.container.margin
    },  
    bg = beautiful.highlight_alt, 
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(4))
    end,
    widget = wibox.container.background
}