local awful = require("awful")
local beautiful = require("beautiful")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")

local main_color = beautiful.highlight
local mute_color = beautiful.misc2

local image_size = 24

local icon =  wibox.widget {
    font = "Fira Mono 14",
    valign = "center", 
    align = "center",
    forced_height = image_size, 
    forced_width = image_size,
    widget = wibox.widget.textbox
}

local progressbar = wibox.widget {
    max_value     = 100,
    color		  = main_color,
    background_color = mute_color,
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 6)
    end,
    forced_height = 4,
    widget = wibox.widget.progressbar
}

local progressbar_container = wibox.widget {
    {
        icon,
        direction     = 'west',
        layout        = wibox.container.rotate,
    },
    {
        progressbar,
        top = 4, 
        bottom = 4,
        widget = wibox.container.margin
    },
    spacing = 16,
    layout = wibox.layout.fixed.horizontal
}

awesome.connect_signal("evil::battery", function(battery)
    progressbar.value = battery.value
    icon.text = battery.image
end)

return progressbar_container