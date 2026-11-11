local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local apply_borders = require("lib.borders")

local get_notification_content = require("widgets.topbar.notifications.notification_content")

beautiful.notification_bg = "#00000000"

local show_notification = function(n)
    naughty.layout.box {
        notification = n,
        type = "notification",
        position = beautiful.notification_position,
        --maximum_width = 300,
        --maximum_height = 78,
        widget_template = apply_borders({
            get_notification_content(n),
            forced_height = 70,
            forced_width = 284,
            bg = beautiful.bg_normal,
            widget = wibox.container.background
        }, 300, 88, 8)
    }
end

return show_notification