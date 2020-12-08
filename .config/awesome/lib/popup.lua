local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require('beautiful').xresources.apply_dpi

local popup = {}

popup.create = function(x, y, height, width, widget) 
    local widgetContainer = wibox.widget {
        {
            widget = wibox.widget.separator,
            color  = '#b8d2f82a',
            forced_height = dpi(1),
        },
        {
            widget, 
            margins = dpi(10), 
            widget = wibox.container.margin
        }, 
        forced_height = height, 
        forced_width = width, 
        layout = wibox.layout.fixed.vertical
    }

    local popupWidget = awful.popup {
        widget = widgetContainer, 
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
        end,
        visible = false, 
        ontop = true, 
        x = x,
        y = y
    }

    --[[local mouseInPopup = false
    local timer = gears.timer {
        timeout   = 1.25,
        single_shot = true,
        callback  = function()
            if not mouseInPopup then
                popupWidget.visible = false 
            end
        end
    }

    popupWidget:connect_signal("mouse::leave", function() 
        if popupWidget.visible then
            mouseInPopup = false
            timer:again()
        end
    end)

    popupWidget:connect_signal("mouse::enter", function()
        mouseInPopup = true
    end)]]--

    return popupWidget
end

popup.separator = function() 
    return wibox.widget {
        widget = wibox.widget.separator,
        color  = '#b8d2f82a',
        forced_height = dpi(1),
    }
end

return popup