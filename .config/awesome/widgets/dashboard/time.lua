local wibox = require("wibox")
local beautiful = require("beautiful")

local hours = wibox.widget.textclock()
hours.font = "Fira Mono 38"
hours.format = "%H"

local minutes = wibox.widget.textclock()
minutes.font = "Fira Mono Bold 38"
minutes.format = "%M"

local point = wibox.widget.textbox()
point.markup = "<span foreground='"..beautiful.red.."'>:</span>"
point.font = "Roboto Bold 32"

return wibox.widget {
    hours, 
    point,
    minutes,
    spacing = 8, 
    layout = wibox.layout.fixed.horizontal
}