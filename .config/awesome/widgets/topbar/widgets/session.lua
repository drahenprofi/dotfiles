local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local button = require("components.button")

local popup = {}

local poweroff = button.create_image_onclick(beautiful.power_grey_icon, beautiful.power_icon, function() awful.spawn("poweroff") end)
local reboot = button.create_image_onclick(beautiful.reboot_grey_icon, beautiful.reboot_icon, function() awful.spawn("reboot") end)
local logout = button.create_image_onclick(beautiful.logout_grey_icon, beautiful.logout_icon, function() awesome.quit() end)
local settings = button.create_image_onclick(beautiful.settings_grey_icon, beautiful.settings_icon, function() 
    awful.spawn("code /home/parndt/awesome") 
    popup.visible = false
end)

local width = 190
local height = 48

local sessionWidget = wibox.widget {
    button.create_image(beautiful.power_grey_icon, beautiful.power_icon), 
    widget = wibox.widget.background
}

local popupWidget = wibox.widget {
    {
        widget = wibox.widget.separator,
        color  = '#b8d2f82a',
        forced_height = 1,
    },
    {
        {
            poweroff, 
            reboot, 
            logout, 
            settings, 
            spacing = 20, 
            layout = wibox.layout.fixed.horizontal
        }, 
        margins = 10, 
        widget = wibox.container.margin
    }, 
    forced_height = height, 
    forced_width = width, 
    layout = wibox.layout.fixed.vertical
}

popup = awful.popup {
    widget = popupWidget, 
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
    end,
    visible = false, 
    ontop = true, 
    x = awful.screen.focused().geometry.width - width - 5, 
    y = beautiful.bar_height + 5,
}

sessionWidget:connect_signal("button::press", function() popup.visible = not popup.visible end)

return sessionWidget