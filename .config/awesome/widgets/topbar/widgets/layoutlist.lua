local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local ll = awful.widget.layoutlist {
    base_layout = wibox.widget {
        spacing         = 10,
        forced_num_cols = 4,
        layout          = wibox.layout.grid.vertical,
    },
    widget_template = {
        {
            {
                id            = 'icon_role',
                forced_height = 22,
                forced_width  = 22,
                widget        = wibox.widget.imagebox,
            },
            margins = 4,
            widget  = wibox.container.margin,
        },
        id              = 'background_role',
        forced_width    = 32,
        forced_height   = 32,
        shape           = gears.shape.rounded_rect,
        widget          = wibox.container.background,
    }
}

return ll