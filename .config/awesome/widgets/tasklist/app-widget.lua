local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi


local get_app_icon = function(is_template)

    local default_icon = nil

    if is_template then 
        default_icon = { 
            {
                awful.widget.clienticon,
                id = "default_icon",
                widget = wibox.container.background, 
            }, 
            left = 6,
            widget = wibox.container.margin
        }
    end

    return {
        {
            {
                nil,
                {
                    bg = beautiful.misc1,
                    id = "selected_indicator",
                    shape = function(cr, width, height)
                        gears.shape.rounded_rect(cr, width, height, 50)
                    end,
                    forced_height = 4,
                    forced_width = 4,
                    widget = wibox.container.background
                },
                nil,
                expand = "none",
                widget = wibox.layout.align.vertical
            },
            left = 3,
            widget = wibox.container.margin
        },
        {
            {
                {
                    id = "custom_icon",
                    font = beautiful.glyph_font.." Nerd Font 22",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox
                },
                default_icon,
                forced_height = 32, 
                forced_width = 32,
                layout = wibox.layout.fixed.vertical
            }, 
            top = 4, 
            bottom = 4,
            widget = wibox.container.margin
        }, 
        layout = wibox.layout.fixed.horizontal
    }
end

return get_app_icon