local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local button = require("components.button")
local popupLib = require("components.popup")

local width = 400
local margin = 10

local notifWidget = wibox.widget {
    button.create_image(beautiful.notification_grey_icon, beautiful.notification_icon), 
    widget = wibox.widget.background
}

local popupWidget = wibox.widget {
    require("widgets.notif-center"),
    expand = "none", 
    layout = wibox.layout.fixed.horizontal
}

local popup = popupLib.create(awful.screen.focused().geometry.width - width - 5, beautiful.bar_height + 5, 
    nil, width, popupWidget)

notifWidget:connect_signal("button::press", function() 
    popup.visible = not popup.visible 
    --naughty.suspended = popup.visible
end)

return notifWidget