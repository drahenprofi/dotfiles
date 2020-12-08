local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local apps = require("config.apps")

local text = wibox.widget {
    text = "Take screenshot", 
    font = "Roboto Medium 12",
    widget = wibox.widget.textbox
}

local icon = wibox.widget {
    markup = "<span foreground='"..beautiful.cyan.."'></span>",
    font = "Fira Mono 32",
    widget = wibox.widget.textbox
}

local widget = wibox.widget {
    icon, 
    text,
    spacing = dpi(24),
    layout = wibox.layout.fixed.horizontal
}

widget:connect_signal("button::press", function()
    awesome.emit_signal("dashboard::toggle")
    -- TODO
    awful.spawn.easy_async_with_shell("sleep 1; ".. apps.screenshot, function(stdout)
    end)
end)

return widget