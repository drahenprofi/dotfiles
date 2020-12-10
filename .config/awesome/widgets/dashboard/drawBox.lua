local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

local function drawBox(content, width, height)
    local margin = 8
    local padding = 16

    local container = wibox.container.background()
    container.bg = beautiful.bg_normal
    container.forced_width = dpi(width + margin + padding)
    container.forced_height = dpi(height + margin + padding)
    container.shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(8))
    end

    container.shape_border_width = dpi(1)
    container.shape_border_color = beautiful.bg_light
    
    local box = wibox.widget {
        {
            {
                {
                    nil,
                    {
                        nil,
                        content,
                        expand = "none",
                        layout = wibox.layout.align.vertical,
                    },
                    expand = "none",
                    layout = wibox.layout.align.horizontal,
                }, 
                margins = dpi(padding),
                widget = wibox.container.margin
            },
            widget = container
        },
        margins = dpi(margin),
        widget = wibox.container.margin
    }

    box.set_background = function(bg)
        container.bg = bg
    end

    return box
end

return drawBox