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
        shape_border_width = dpi(1),
        shape_border_color = beautiful.bg_light,
        widget = wibox.container.background
    }

    local old_cursor, old_wibox
    container:connect_signal("mouse::enter", function()
        textbox.markup = "<span foreground='"..fg_hover.."'>"..text.."</span>"
        textbox.font = "Fira Mono 36"
        container.bg = beautiful.bg_dark

        -- change cursor
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand2" 
    end)

    container:connect_signal("mouse::leave", function()
        textbox.markup = "<span foreground='"..fg.."'>"..text.."</span>"
        textbox.font = "Fira Mono 28" 
        container.bg = beautiful.bg_normal

        -- reset cursor
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    container:connect_signal("button::press", function() 
        onclick()
        awesome.emit_signal("dashboard::toggle")
    end)

    return container
end