local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")

local button = require("components.button")
local popupLib = require("components.popup")
local widget = require("widgets.topbar.widgets.volume-watcher")

local GET_VOLUME_CMD = 'amixer -D pulse sget Master'
local INC_VOLUME_CMD = 'amixer -D pulse sset Master 5%+'
local DEC_VOLUME_CMD = 'amixer -D pulse sset Master 5%-'
local TOG_VOLUME_CMD = 'amixer -D pulse sset Master toggle'

local popup = {}

local width = 325
local height = 48

local volumeWidget = wibox.widget {
    button.create_image(beautiful.volume_up_grey_icon, beautiful.volume_up_icon), 
    widget = wibox.widget.background
}

local popupWidget = wibox.widget {
    widget(), 
    spacing = 5,
    layout = wibox.layout.align.horizontal
}

popup = popupLib.create(awful.screen.focused().geometry.width - width - 5, beautiful.bar_height + 5, 
    height, width, popupWidget)

volumeWidget:connect_signal("button::press", function() popup.visible = not popup.visible end)

return volumeWidget