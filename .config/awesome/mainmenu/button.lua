local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")

local button = {}

button.create = function(width, height, image, command)
    local button_image = wibox.widget {
        image = image, 
        forced_height = height, 
        forced_width = width, 
        widget = wibox.widget.imagebox
    }

    local button = wibox.widget {
        {
            button_image, 
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

    button.update_image = function(image)
        button_image.image = image
    end

    return button
end

button.create_text = function(text, font, command)
    local button = wibox.widget {
        {
            {
                markup = text,
                font = font, 
                align  = 'center',
                valign = 'center',
                widget = wibox.widget.textbox
            },
            margins = dpi(10),
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

button.create_widget = function(widget, command)
    local button = wibox.widget {
        {
            widget, 
            margins = dpi(10),
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