local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local menu = {}

local poweroff = wibox.widget {
    forced_height = 48, 
    image = beautiful.power_icon, 
    widget = wibox.widget.imagebox
}

poweroff:connect_signal("button::press", function() awful.spawn("poweroff") end)

awful.screen.connect_for_each_screen(function(s)
    menu = wibox {
        screen = s,
        height = awful.screen.focused().geometry.height, 
        width = awful.screen.focused().geometry.width, 
        bg = beautiful.misc2 .. "26", 
        --bgimage = beautiful.wallpaper,
        visible = false, 
        ontop = true
    }

    menu:connect_signal("button::press", function() menu.visible = false end)

    menu:setup {
        nil, 
        {
            nil, 
            {
                poweroff,             
                layout = wibox.layout.fixed.horizontal
            },
            nil,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        nil,
        expand = "none",
        layout = wibox.layout.align.vertical
    }
end)

menu.toggle = function()
    menu.visible = not menu.visible
end

return menu