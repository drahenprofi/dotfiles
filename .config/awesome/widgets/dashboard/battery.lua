local awful = require("awful")
local beautiful = require("beautiful")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")

local main_color = beautiful.highlight
local mute_color = beautiful.misc2

local image_size = 28

local icon =  wibox.widget {
    image = beautiful.brightness_icon, 
    forced_height = image_size, 
    forced_width = image_size,
    widget = wibox.widget.imagebox
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
    nil,
    {
        {
            progressbar, 
            direction     = 'east',
            layout        = wibox.container.rotate,
        },
        left = 4, 
        right = 4, 
        bottom = 8,
        widget = wibox.container.margin
    },
    icon, 
    layout = wibox.layout.align.vertical
}

awesome.connect_signal("evil::battery", function(battery)
    progressbar.value = battery.charge
    icon.image = battery.image
end)

return progressbar_container