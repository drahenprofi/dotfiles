local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local button = require("components.button")

local notifbox = {}

notifbox.create = function(icon, title, message, width)
    local time = os.date("%H:%M") 
    local box = {}

    local dismiss = button.create_image_onclick(beautiful.delete_grey_icon, beautiful.delete_icon, function() 
        _G.remove_notifbox(box)
    end)
    dismiss.forced_height = dpi(24)
    dismiss.forced_width = dpi(24)

    box = wibox.widget {
        {
            {
                image = icon, 
                forced_width = beautiful.notification_icon_size, 
                forced_height = beautiful.notification_icon_size,
                widget = wibox.widget.imagebox
            }, 
            {
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
                left = dpi(10), 
                widget = wibox.container.margin
            }, 
            {
                {
                    {
                        font = "Roboto Regular 10",
                        markup = time, 
                        widget = wibox.widget.textbox
                    }, 
                    {
                        nil, 
                        dismiss,
                        nil, 
                        expand = "none", 
                        layout = wibox.layout.align.horizontal
                    }, 
                    spacing = dpi(5), 
                    layout = wibox.layout.fixed.vertical
                }, 
                margins = dpi(10), 
                widget = wibox.container.margin
            }, 
            spacing = dpi(20), 
            layout = wibox.layout.align.horizontal
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