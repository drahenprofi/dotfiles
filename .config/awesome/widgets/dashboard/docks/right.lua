local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local apps = require("config.apps")
local box = require("widgets.dashboard.docks.dockbox")

local poweroff = box(beautiful.fg_normal, beautiful.fg_focus, "󰐥", function() awful.spawn("poweroff") end)
local reboot = box(beautiful.fg_normal, beautiful.fg_focus, "󰜉", function() awful.spawn("reboot") end)
local logout = box(beautiful.fg_normal, beautiful.fg_focus, "󰗽", function() awesome.quit() end)

return wibox.widget {
    {
        nil,
        {
            nil, 
            {
                poweroff,
                reboot, 
                logout,
                spacing = dpi(8),
                layout = wibox.layout.fixed.vertical
            }, 
            nil,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        nil, 
        expand = "none", 
        layout = wibox.layout.align.vertical
    }, 
    forced_width = dpi(64),
    widget = wibox.container.background, 
}