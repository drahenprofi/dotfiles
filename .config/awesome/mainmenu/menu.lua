local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")

local appmenu = require("mainmenu.appmenu")

local menu = {}

local box = function(content, width, height, margin)
    local box_widget = wibox.widget {
        {
            {
                nil,
                {
                    {
                        nil,
                        content,
                        expand = "none",
                        layout = wibox.layout.align.vertical
                    },
                    margins = dpi(10),
                    widget = wibox.container.margin,
                },
                expand = "none",
                layout = wibox.layout.align.horizontal
            },
            bg = beautiful.bg_normal,
            forced_height = dpi(height),
            forced_width = dpi(width),
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
            end,
            widget = wibox.container.background
        },
        margins = dpi(margin),
        color = "#00000000",
        widget = wibox.container.margin
    }

    return box_widget
end

awful.screen.connect_for_each_screen(function(s)
    menu = wibox {
        screen = s,
        height = awful.screen.focused().geometry.height, 
        width = awful.screen.focused().geometry.width, 
        bg = beautiful.misc2 .. "26", 
        visible = false, 
        ontop = true
    }

    menu:connect_signal("button::press", function() menu.visible = false end)

    menu:setup {
        {
            {
                box(appmenu, 100, 200, 10), 
                expand = "none",
                layout = wibox.layout.align.vertical
            },
            margins = dpi(100),
            widget = wibox.container.margin,
        }, 
        layout = wibox.layout.align.horizontal, 
    }
end)

menu.toggle = function()
    menu.visible = not menu.visible
end

return menu