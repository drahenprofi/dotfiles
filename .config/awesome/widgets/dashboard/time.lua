local wibox = require("wibox")
local beautiful = require("beautiful")

local hours = wibox.widget.textclock()
hours.font = "JetBrains Mono 38"
hours.format = "%H"

local minutes = wibox.widget.textclock()
minutes.font = "JetBrains Mono 38"
minutes.format = "<span foreground='"..beautiful.red.."'>%M</span>"

return wibox.widget {
    hours, 
    minutes,
    spacing = 8, 
    layout = wibox.layout.fixed.horizontal
}