local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local button = require("components.button")
local widget = require("widgets.topbar.widgets.volume-watcher") 

local GET_VOLUME_CMD = 'amixer -D pulse sget Master'
local INC_VOLUME_CMD = 'amixer -D pulse sset Master 5%+'
local DEC_VOLUME_CMD = 'amixer -D pulse sset Master 5%-'
local TOG_VOLUME_CMD = 'amixer -D pulse sset Master toggle'

local popup = {}

local width = 190
local height = 48

local volumeWidget = wibox.widget {
    button.create_image(beautiful.volume_up_grey_icon, beautiful.volume_up_icon), 
    widget = wibox.widget.background
}

local popupWidget = wibox.widget {
    {
        widget = wibox.widget.separator,
        color  = '#b8d2f82a',
        forced_height = 1,
    },
    {
        {
            widget(), 
            spacing = 20, 
            layout = wibox.layout.fixed.horizontal
        }, 
        margins = 10, 
        widget = wibox.container.margin
    }, 
    forced_height = height, 
    forced_width = width, 
    layout = wibox.layout.fixed.vertical
}

popup = awful.popup {
    widget = popupWidget, 
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
    end,
    visible = false, 
    ontop = true, 
    x = awful.screen.focused().geometry.width - width - 5, 
    y = beautiful.bar_height + 5,
}

volumeWidget:connect_signal("button::press", function() popup.visible = not popup.visible end)

return volumeWidget