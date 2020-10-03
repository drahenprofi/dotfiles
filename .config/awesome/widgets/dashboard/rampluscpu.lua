local wibox = require("wibox")

local ram = require("widgets.dashboard.ram")
local cpu = require("widgets.dashboard.cpu")

return wibox.widget {
    nil, 
    {
        cpu(),
        ram(), 
        spacing = 16,
        layout = wibox.layout.fixed.horizontal,
    },
    nil, 
    expand = "none",  
    layout = wibox.layout.fixed.vertical
}