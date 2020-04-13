local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local button = require("components.button")
local popupLib = require("components.popup")

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
    poweroff, 
    reboot, 
    logout, 
    settings, 
    spacing = 20, 
    layout = wibox.layout.fixed.horizontal
}

popup = popupLib.create(5, beautiful.bar_height + 5, height, width, popupWidget)

sessionWidget:connect_signal("button::press", function() popup.visible = not popup.visible end)

return sessionWidget