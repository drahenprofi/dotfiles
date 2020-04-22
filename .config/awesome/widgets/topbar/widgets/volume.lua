local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local apps = require("config.apps")

local button = require("components.button")
local popupLib = require("components.popup")
local widget = require("widgets.topbar.widgets.volume-watcher")

local GET_VOLUME_CMD = 'amixer -D pulse sget Master'
local INC_VOLUME_CMD = 'amixer -D pulse sset Master 5%+'
local DEC_VOLUME_CMD = 'amixer -D pulse sset Master 5%-'
local TOG_VOLUME_CMD = 'amixer -D pulse sset Master toggle'

local popup = {}

local width = 275
local height = 95

local volumeWidget = wibox.widget {
    button.create_image(beautiful.volume_up_grey_icon, beautiful.volume_up_icon), 
    widget = wibox.widget.background
}

local volumeCtrl = button.create_text("#cccccc", "#ffffff", "Volume Control...", "Roboto Regular 10")
volumeCtrl:connect_signal("button::press", function()
    awful.spawn(apps.volume)
    popup.visible = false
end)

local popupWidget = wibox.widget {
    widget(), 
    popupLib.separator(), 
    volumeCtrl,
    spacing = 10,
    layout = wibox.layout.fixed.vertical
}

popup = popupLib.create(awful.screen.focused().geometry.width - width - 5, beautiful.bar_height + 5, 
    height, width, popupWidget)

volumeWidget:connect_signal("button::press", function() popup.visible = not popup.visible end)

return volumeWidget