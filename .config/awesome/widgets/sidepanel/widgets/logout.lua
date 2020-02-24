local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")

local button = require("components.button")

local sleep = button.create(beautiful.sleep_icon, 36, 50, 10, beautiful.bg_light, beautiful.bg_normal, beautiful.bg_very_light, function() awful.spawn("systemctl suspend") end)
local poweroff = button.create(beautiful.power_icon, 36, 50, 10, beautiful.bg_light, beautiful.bg_normal, beautiful.bg_very_light, function() awful.spawn("poweroff") end)
local reboot = button.create(beautiful.reboot_icon, 36, 50, 10, beautiful.bg_light, beautiful.bg_normal, beautiful.bg_very_light, function() awful.spawn("reboot") end)
local logout = button.create(beautiful.logout_icon, 36, 50, 10, beautiful.bg_light, beautiful.bg_normal, beautiful.bg_very_light, awesome.quit)

local logout_widget = wibox.widget {
    {
        {
            nil, 
            {
                sleep, 
                poweroff, 
                reboot, 
                logout, 
                spacing = 20, 
                layout = wibox.layout.fixed.horizontal
            }, 
            nil, 
            expand = "none", 
            layout = wibox.layout.align.horizontal
        }, 
        top = 5, 
        bottom = 5, 
        widget = wibox.container.margin
    }, 
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(50))
    end,
    bg = beautiful.bg_light, 
    widget = wibox.container.background
}

return logout_widget