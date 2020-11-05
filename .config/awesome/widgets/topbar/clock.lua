local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local gears = require("gears")
local awful = require("awful")

local clock_format = "%A %B %d, %H:%M"

local clock = wibox.widget.textclock()
clock.font = "Roboto Bold 10"
clock.format = "<span foreground='#cccccc'>"..clock_format.."</span>"
clock.fg = beautiful.bg_normal

return clock