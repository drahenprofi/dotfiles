local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")

local opener = {}

opener.init = function(s)
    local image = wibox.widget {
        image = beautiful.open_panel_icon, 
        widget = wibox.widget.imagebox
    }

    local widget = wibox.widget {
        image, 
        widget = wibox.container.background
    }

    widget:connect_signal("button::press", function()
        s.sidepanel.toggle()

        if s.sidepanel.visible then
            image.image = beautiful.close_panel_icon
        else
            image.image = beautiful.open_panel_icon
        end
    end)

    awesome.connect_signal("sidepanel::visible", function(visible)
        if visible then
            image.image = beautiful.close_panel_icon
        else
            image.image = beautiful.open_panel_icon
        end
    end)

    return widget
end

return opener