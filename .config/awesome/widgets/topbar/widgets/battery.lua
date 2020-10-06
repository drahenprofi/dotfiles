-------------------------------------------------
-- Battery Widget for Awesome Window Manager
-- Shows the battery status using the ACPI tool
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/battery-widget

-- @author Pavel Makhov
-- @copyright 2017 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gfs = require("gears.filesystem")
local dpi = require('beautiful').xresources.apply_dpi

-- acpi sample outputs
-- Battery 0: Discharging, 75%, 01:51:38 remaining
-- Battery 0: Charging, 53%, 00:57:43 until charged

local HOME = os.getenv("HOME")

local battery_widget = {}

local icon_widget = wibox.widget {
    id = "icon",
    image = beautiful.battery_alert_icon, 
    widget = wibox.widget.imagebox,
}
local level_widget = wibox.widget {
    markup = "0%", 
    font = "Roboto Bold 10",
    widget = wibox.widget.textbox
}

battery_widget = wibox.widget {
    icon_widget,
    level_widget,
    spacing = dpi(2),
    layout = wibox.layout.fixed.horizontal,
}

awesome.connect_signal("evil::battery", function(battery)
    icon_widget.image = battery.image
    level_widget.markup = "<span foreground='#cccccc'>"..battery.charge.."%</span>"
end)

return battery_widget