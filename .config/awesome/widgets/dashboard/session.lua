local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local button = require("components.button")
local popupLib = require("components.popup")


local popup = {}

local poweroff = button.create_image_onclick(beautiful.power_grey_icon, beautiful.power_icon, function() awful.spawn("poweroff") end)
local reboot = button.create_image_onclick(beautiful.reboot_grey_icon, beautiful.reboot_icon, function() awful.spawn("reboot") end)
local logout = button.create_image_onclick(beautiful.logout_grey_icon, beautiful.logout_icon, function() awesome.quit() end)

return wibox.widget {
    poweroff, 
    reboot, 
    logout,
    spacing = dpi(18),
    layout = wibox.layout.fixed.horizontal
}