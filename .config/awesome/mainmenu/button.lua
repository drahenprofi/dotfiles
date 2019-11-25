local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")

local button = {}

button.create = function(width, height, image, command)
    local button = wibox.widget {
        {
            {
                image = image, 
                forced_height = height, 
                forced_width = width, 
                widget = wibox.widget.imagebox
            },
            margins = dpi(5),
            widget = wibox.container.margin,
        }, 
        bg = beautiful.bg_normal, 
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(10))
        end,
        widget = wibox.container.background 
    }

    button:connect_signal("button::press", function()
        button.bg = beautiful.bg_very_light
        command()
    end)

    button:connect_signal("button::leave", function() button.bg = beautiful.bg_normal end)
    button:connect_signal("mouse::enter", function() button.bg = beautiful.bg_light end)
    button:connect_signal("mouse::leave", function() button.bg = beautiful.bg_normal end)

    return button
end

return button