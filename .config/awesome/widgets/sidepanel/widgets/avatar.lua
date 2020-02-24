local wibox = require("wibox")
local beautiful = require("beautiful")

local avatar = wibox.widget {
    nil, 
    {
        {
            image = beautiful.avatar, 
            forced_height = 200, 
            widget = wibox.widget.imagebox
        },
        layout = wibox.layout.align.vertical
    },
    nil, 
    expand = "none",
    layout = wibox.layout.align.horizontal
}

return avatar