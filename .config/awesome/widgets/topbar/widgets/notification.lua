local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local button = require("components.button")


local width = 400
local height = awful.screen.focused().geometry.height - 10- beautiful.bar_height
local margin = 10

local notifWidget = wibox.widget {
    button.create_image(beautiful.notification_grey_icon, beautiful.notification_icon), 
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
            require("widgets.notif-center"),
            expand = "none", 
            layout = wibox.layout.fixed.horizontal
        },
        margins = margin, 
        widget = wibox.container.margin
    }, 
    forced_height = height, 
    forced_width = width,
    layout = wibox.layout.fixed.vertical
}

local popup = awful.popup {
    widget = popupWidget, 
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
    end,
    visible = false, 
    ontop = true, 
    x = awful.screen.focused().geometry.width - width - 5, 
    y = beautiful.bar_height + 5
}

notifWidget:connect_signal("button::press", function() 
    popup.visible = not popup.visible 
    --naughty.suspended = popup.visible
end)

return notifWidget