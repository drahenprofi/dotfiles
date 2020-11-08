local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

return function(fg, fg_hover, text, onclick)
    local textbox = wibox.widget {
        markup = "<span foreground='"..fg.."'>"..text.."</span>",
        font = "Fira Mono 28",
        align = "center",
        valign = "center",
        forced_width = dpi(56), 
        forced_height = dpi(56), 
        widget = wibox.widget.textbox
    }

    local container = wibox.widget {
        textbox,
        bg = beautiful.bg_normal, 
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(8))
        end,
        widget = wibox.container.background
    }

    container:connect_signal("mouse::enter", function()
        textbox.markup = "<span foreground='"..fg_hover.."'>"..text.."</span>"
        textbox.font = "Fira Mono 36"
        container.bg = beautiful.bg_dark
    end)

    container:connect_signal("mouse::leave", function()
        textbox.markup = "<span foreground='"..fg.."'>"..text.."</span>"
        textbox.font = "Fira Mono 28" 
        container.bg = beautiful.bg_normal
    end)

    container:connect_signal("button::press", function() 
        awful.spawn(onclick, false)
        awesome.emit_signal("dashboard::toggle")
    end)

    return container
end