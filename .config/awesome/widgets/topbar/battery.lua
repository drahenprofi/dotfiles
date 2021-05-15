local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require('beautiful').xresources.apply_dpi

local battery_widget = {}

local icon_widget = wibox.widget {
    font = "FiraMono Nerd Font 10",
    widget = wibox.widget.textbox,
}
local level_widget = wibox.widget {
    markup = "0%", 
    font = "Roboto Medium 10",
    widget = wibox.widget.textbox
}

battery_widget = wibox.widget {
    icon_widget,
    level_widget,
    spacing = dpi(4),
    layout = wibox.layout.fixed.horizontal,
}

awesome.connect_signal("evil::battery", function(battery)
    icon_widget.markup = "<span foreground='"..beautiful.fg_dark.."'>"..battery.image.."</span>"
    level_widget.markup = "<span foreground='"..beautiful.fg_dark.."'>"..battery.value.."%</span>"
end)

return battery_widget