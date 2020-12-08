local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require('beautiful').xresources.apply_dpi

local battery_widget = {}

local icon_widget = wibox.widget {
    font = "Fira Mono 10",
    widget = wibox.widget.textbox,
}
local level_widget = wibox.widget {
    markup = "0%", 
    font = "Roboto Medium 10",
    widget = wibox.widget.textbox
}

battery_widget = wibox.widget {
    {
        {
            icon_widget,
            level_widget,
            spacing = dpi(4),
            layout = wibox.layout.fixed.horizontal,
        },
        left = dpi(4), right = dpi(4),
        widget = wibox.container.margin
    }, 
    bg = beautiful.yellow,
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(4))
    end,
    widget = wibox.container.background
}

awesome.connect_signal("evil::battery", function(battery)
    icon_widget.markup = "<span foreground='"..beautiful.bg_normal.."'>"..battery.image.."</span>"
    level_widget.markup = "<span foreground='"..beautiful.bg_normal.."'>"..battery.value.."%</span>"

    if battery.value > 50 then
        battery_widget.bg = beautiful.green
    elseif battery.value > 10 then
        battery_widget.bg = beautiful.yellow
    else 
        battery_widget.bg = beautiful.red
    end
end)

return battery_widget