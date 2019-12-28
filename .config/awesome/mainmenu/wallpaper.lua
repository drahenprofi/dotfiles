local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

local wallpaper = wibox.widget {
    {
        {
            image = beautiful.wallpaper, 
            forced_width = 250, 
            widget = wibox.widget.imagebox
        }, 
        margins = dpi(20),
        widget = wibox.container.margin
    }, 
    {
        {
            markup = "<span color='" .. beautiful.highlight_alt .. "'>" .. os.getenv("HOME") .. "</span>",
            font = "Roboto Bold 16", 
            align = "center", 
            valign = "center", 
            widget = wibox.widget.textbox
        }, 
        margins = dpi(10),
        widget = wibox.container.margin
    },
    layout = wibox.layout.align.vertical
}

return wallpaper