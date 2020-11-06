local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local button = require("components.button")
local dashboard = require("widgets.dashboard")

local color = beautiful.blue
local color_hover = beautiful.blue_light

local sessionWidget = wibox.widget {
    button.create_text(color, color_hover, "", "Fira Mono 20"), 
    widget = wibox.widget.background
}

sessionWidget:connect_signal("button::press", dashboard.toggle)

return sessionWidget