local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local button = require("components.button")
local dashboard = require("widgets.dashboard")

local sessionWidget = wibox.widget {
    button.create_image(beautiful.start_grey_icon, beautiful.start_icon), 
    widget = wibox.widget.background
}

sessionWidget:connect_signal("button::press", dashboard.toggle)

return sessionWidget