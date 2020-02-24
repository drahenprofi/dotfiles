local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local button = require("components.button")

local settings = button.create(beautiful.settings_icon, 32, 50, 10, beautiful.bg_normal, beautiful.bg_light, beautiful.bg_very_light, function() awful.spawn("code /home/parndt/.config/awesome") end)

return wibox.widget {
    {
        nil, 
        nil,
        settings, 
        expand = "none",
        layout = wibox.layout.align.horizontal
    }, 
    bottom = 20,
    widget = wibox.container.margin
}