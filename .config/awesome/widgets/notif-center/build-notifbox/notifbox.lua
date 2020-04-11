local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local notifbox = {}

notifbox.create = function(icon, title, message, width)
    local box = wibox.widget {
        {
            {
                image = icon, 
                forced_width = beautiful.notification_icon_size, 
                forced_height = beautiful.notification_icon_size,
                widget = wibox.widget.imagebox
            }, 
            {
                nil, 
                {
                    {
                        font = "Roboto Bold 12", 
                        markup = title, 
                        widget = wibox.widget.textbox
                    }, 
                    {
                        font = "Roboto Regular 10", 
                        markup = message, 
                        widget = wibox.widget.textbox
                    },
                    layout = wibox.layout.fixed.vertical
                },  
                expand = "none", 
                layout = wibox.layout.align.vertical
            }, 
            spacing = dpi(10), 
            layout = wibox.layout.fixed.horizontal
        }, 
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
        end, 
        bg = beautiful.bg_light, 
        forced_width = width,  
        widget = wibox.container.background 
    }

    return box
end

return notifbox